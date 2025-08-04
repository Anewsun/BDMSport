import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  FirebaseAuth get auth => _auth;

  AuthRepository({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _auth = firebaseAuth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

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

      final newUser = UserModel(
        id: user.uid,
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
      );

      final userMap = newUser.toMap()
        ..remove('id')
        ..['createdAt'] = FieldValue.serverTimestamp()
        ..['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(user.uid).set(userMap);

      await user.sendEmailVerification();
    } catch (e) {
      if (_auth.currentUser != null) {
        await _auth.currentUser!.delete();
      }
      rethrow;
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

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore.collection('users').doc(user.uid).get();
      if (snapshot.exists) {
        final model = UserModel.fromMap(snapshot.data()!);
        final isVerified = user.emailVerified;

        // Nếu đã xác minh và status vẫn là inactive → cập nhật Firestore
        if (isVerified && model.status != 'active') {
          final updatedModel = model.activateAccount();
          await _firestore.collection('users').doc(user.uid).update({
            'isEmailVerified': true,
            'status': 'active',
            'updatedAt': FieldValue.serverTimestamp(),
          });
          return updatedModel;
        }

        return model;
      }
    }
    return null;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});
