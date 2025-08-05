import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _auth = firebaseAuth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('Không thể tạo người dùng');

      await user.updateDisplayName(name);

      await _createUserDocument(uid: user.uid, name: name, email: email);

      await user.sendEmailVerification();
    } catch (e) {
      await _cleanupOnError();
      rethrow;
    }
  }

  Future<void> _createUserDocument({
    required String uid,
    required String name,
    required String email,
  }) async {
    final newUser = UserModel(
      id: uid,
      name: name,
      email: email,
      phone: null,
      provider: 'local',
      isEmailVerified: false,
      address: null,
      role: 'customer',
      avatar:
          'https://firebasestorage.googleapis.com/v0/b/bdmsport-1dcb2.firebasestorage.app/o/default-avatar.jpg?alt=media',
      status: 'inactive',
      tier: 'Copper',
      balance: 0.0,
      favoriteCourts: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ).toMap();

    await _firestore.collection('users').doc(uid).set({
      ...newUser,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _cleanupOnError() async {
    if (_auth.currentUser != null) {
      await _auth.currentUser!.delete();
    }
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user != null && !userCredential.user!.emailVerified) {
      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: 'Email chưa được xác minh',
      );
    }
  }

  Future<void> signOut() async => await _auth.signOut();

  Future<void> verifyEmailAndActivate() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await user.reload();
    if (!user.emailVerified) return;

    final userDoc = _firestore.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();

    if (snapshot.exists && snapshot.data()?['isEmailVerified'] != true) {
      await userDoc.update({
        'isEmailVerified': true,
        'status': 'active',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    await user.reload();
    final snapshot = await _firestore.collection('users').doc(user.uid).get();

    if (!snapshot.exists) return null;

    final model = UserModel.fromMap(snapshot.data()!);

    return user.emailVerified && model.status != 'active'
        ? await _activateUser(user.uid, model)
        : model;
  }

  Future<UserModel> _activateUser(String uid, UserModel model) async {
    await _firestore.collection('users').doc(uid).update({
      'isEmailVerified': true,
      'status': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return model.copyWith(isEmailVerified: true, status: 'active');
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final emailVerificationProvider = StreamProvider.autoDispose((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges.asyncMap((user) async {
    if (user != null) {
      await authRepo.verifyEmailAndActivate();
    }
    return user;
  });
});

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  return ref.read(authRepositoryProvider).getCurrentUser();
});
