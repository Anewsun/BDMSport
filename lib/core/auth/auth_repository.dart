import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FacebookAuth _facebookAuth;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
  }) : _auth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _facebookAuth = facebookAuth ?? FacebookAuth.instance;

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

  Future<UserModel?> signInWithGoogle() async {
    try {
      final signIn = GoogleSignIn.instance;
      await signIn.initialize();

      final account = await signIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      final auth = account.authentication;
      final idToken = auth.idToken;

      final authorization = await account.authorizationClient
          .authorizationForScopes(['email', 'profile']);
      final accessToken = authorization?.accessToken;

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      return await _handleSocialSignIn(credential, 'google', signIn);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> signInWithFacebook() async {
    try {
      final result = await _facebookAuth.login();
      if (result.status != LoginStatus.success) return null;

      final accessToken = result.accessToken;
      if (accessToken == null) return null;

      final credential = FacebookAuthProvider.credential(
        accessToken.tokenString,
      );

      return await _handleSocialSignIn(credential, 'facebook');
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> _handleSocialSignIn(
    OAuthCredential credential,
    String provider, [
    GoogleSignIn? googleSignIn,
  ]) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return null;

      final existingUser = await _checkExistingEmail(user.email ?? '');
      if (existingUser &&
          user.providerData.any((p) => p.providerId != '$provider.com')) {
        await _auth.signOut();
        if (provider == 'google' && googleSignIn != null) {
          await googleSignIn.disconnect();
        } else {
          await _facebookAuth.logOut();
        }
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'Email này đã được sử dụng với phương thức đăng nhập khác',
        );
      }

      return await _handleSocialLoginUser(
        uid: user.uid,
        name: user.displayName ?? 'User',
        email: user.email ?? '',
        provider: provider,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> _checkExistingEmail(String email) async {
    if (email.isEmpty) return false;
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<UserModel> _handleSocialLoginUser({
    required String uid,
    required String name,
    required String email,
    required String provider,
  }) async {
    final userDoc = _firestore.collection('users').doc(uid);
    final snapshot = await userDoc.get();

    if (!snapshot.exists) {
      final newUser = UserModel(
        id: uid,
        name: name,
        email: email,
        provider: provider,
        isEmailVerified: true,
        role: 'customer',
        status: 'active',
        tier: 'Copper',
        balance: 0.0,
        favoriteCourts: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ).toMap();

      await userDoc.set({
        ...newUser,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await userDoc.update({
        'provider': provider,
        'isEmailVerified': true,
        'status': 'active',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    final updatedSnapshot = await userDoc.get();
    return UserModel.fromMap(updatedSnapshot.data()!);
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
