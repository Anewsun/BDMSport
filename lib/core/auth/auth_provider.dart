import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/user_model.dart';
import 'auth_repository.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authSubscription;

  AuthNotifier(this._authRepository) : super(const AuthState(isLoading: true)) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _syncUserState();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }

    _authSubscription = _authRepository.auth.authStateChanges().listen((
      _,
    ) async {
      await _syncUserState();
    });
  }

  Future<void> _syncUserState() async {
    final user = await _authRepository.getCurrentUser();
    state = state.copyWith(
      user: user,
      isLoading: false,
      error: user == null ? 'Không tìm thấy người dùng' : null,
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _syncUserState();
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        error: e.message ?? 'Đăng nhập thất bại',
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
);
