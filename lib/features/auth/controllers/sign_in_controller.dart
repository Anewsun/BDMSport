import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

class SignInController extends Notifier<AuthState> implements Listenable {
  final List<VoidCallback> _listeners = [];

  @override
  AuthState build() => const AuthState();

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  Future<void> _syncUserState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        final model = UserModel.fromMap(snapshot.data()!);
        state = state.copyWith(user: model, isLoading: false);
        _notifyListeners();
      }
    } else {
      state = state.copyWith(user: null, isLoading: false);
      _notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      _notifyListeners();

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

      await _syncUserState();
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(error: e, isLoading: false);
      _notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    state = const AuthState();
    _notifyListeners();
  }

  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
    _notifyListeners();
  }
}
