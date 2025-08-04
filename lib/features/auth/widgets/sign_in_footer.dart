import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignInFooter extends StatelessWidget {
  const SignInFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text.rich(
          TextSpan(
            text: 'Chưa có tài khoản? ',
            style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
            children: [
              TextSpan(
                text: 'Đăng ký',
                style: const TextStyle(
                  color: Color(0xFF1167B1),
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    context.push('/sign-up');
                  },
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
