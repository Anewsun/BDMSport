import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/utils/error_util.dart';

final signUpControllerProvider = Provider<SignUpController>((ref) {
  return SignUpController(ref);
});

class SignUpController {
  final Ref ref;

  SignUpController(this.ref);

  Future<void> signUp({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await ref
          .read(authRepositoryProvider)
          .signUp(name: name, email: email, password: password);

      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Đăng ký thành công'),
          content: Text(
            'Một email xác minh đã được gửi đến $email. '
            'Vui lòng kiểm tra hộp thư và xác minh email trước khi đăng nhập.',
          ),
          actions: [
            TextButton(
              onPressed: () => context.go('/sign-in'),
              child: const Text('Đã hiểu'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(getFriendlyErrorMessage(e))));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi đăng ký: ${e.toString()}')));
    }
  }
}
