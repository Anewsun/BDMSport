import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_provider.dart';

final signInControllerProvider = Provider.autoDispose<SignInController>((ref) {
  return SignInController(ref);
});

class SignInController {
  final Ref ref;
  FirebaseAuthException? error;

  SignInController(this.ref);

  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return false;
    }

    final notifier = ref.read(authProvider.notifier);

    try {
      error = null;
      notifier.setLoading(true);
      await notifier.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && !currentUser.emailVerified) {
        error = FirebaseAuthException(
          code: 'email-not-verified',
          message:
              'Email chưa được xác minh. Vui lòng kiểm tra hộp thư của bạn.',
        );
        await FirebaseAuth.instance.signOut();
        return false;
      }

      return true;
    } on FirebaseAuthException catch (e) {
      error = e;
      return false;
    } finally {
      notifier.setLoading(false);
    }
  }

  bool get isLoading => ref.read(authProvider).isLoading;

  String? get errorMessage {
    if (error == null) return null;
    return error!.message ?? 'Đăng nhập thất bại';
  }
}
