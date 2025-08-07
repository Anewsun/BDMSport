import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/models/user_model.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final dynamic error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UserModel? user, bool? isLoading, dynamic error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final signInControllerProvider = NotifierProvider<SignInController, AuthState>(
  SignInController.new,
);

class SignInController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState(isLoading: false);
  }

  Future<void> initializeAuthState() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await syncUserState();
      } else {
        state = const AuthState(isLoading: false);
      }
    } catch (e, st) {
      state = AuthState(isLoading: false, error: e);
      debugPrint('Error initializing auth state: $e\n$st');
    }
  }

  Future<void> syncUserState() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        state = state.copyWith(user: null, isLoading: false);
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!snapshot.exists) {
        state = state.copyWith(user: null, isLoading: false);
        return;
      }

      final model = UserModel.fromMap(snapshot.data()!..['id'] = snapshot.id);
      state = state.copyWith(user: model, isLoading: false);
    } catch (e, st) {
      state = state.copyWith(error: e, isLoading: false);
      debugPrint('Error syncing user state: $e\n$st');
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!credential.user!.emailVerified) {
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Email chưa xác minh.',
        );
      }

      await syncUserState();
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(error: e, isLoading: false);
      return false;
    } catch (e, st) {
      state = state.copyWith(error: e, isLoading: false);
      debugPrint('Login error: $e\n$st');
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn.instance.signOut();
      await FacebookAuth.instance.logOut();

      state = const AuthState(isLoading: false);
    } catch (e, st) {
      state = AuthState(isLoading: false, error: e);
      debugPrint('Sign out error: $e\n$st');
    }
  }

  Future<bool> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.signInWithGoogle();

      if (user != null) {
        await syncUserState();
        return true;
      }
      return false;
    } catch (e, st) {
      state = state.copyWith(error: e, isLoading: false);
      debugPrint('Google login error: $e\n$st');
      return false;
    }
  }

  Future<bool> loginWithFacebook() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.signInWithFacebook();

      if (user != null) {
        await syncUserState();
        return true;
      }
      return false;
    } catch (e, st) {
      state = state.copyWith(error: e, isLoading: false);
      debugPrint('Facebook login error: $e\n$st');
      return false;
    }
  }

  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  void updateUser(UserModel newUser) {
    state = state.copyWith(user: newUser);
  }
}
