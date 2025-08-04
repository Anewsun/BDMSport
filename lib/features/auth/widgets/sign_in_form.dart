import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/input_field.dart';
import '../../../core/widgets/password_field.dart';
import '../controllers/sign_in_controller.dart';

class SignInForm extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;
  final bool autoValidate;
  final Function(String?) onEmailSaved;
  final Function(String?) onPasswordSaved;
  final VoidCallback onLoginPressed;
  final VoidCallback toggleShowPassword;
  final bool showPassword;

  const SignInForm({
    super.key,
    required this.formKey,
    required this.autoValidate,
    required this.onEmailSaved,
    required this.onPasswordSaved,
    required this.onLoginPressed,
    required this.toggleShowPassword,
    required this.showPassword,
  });

  @override
  ConsumerState<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<SignInForm> {
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(signInControllerProvider).isLoading;

    return Form(
      key: widget.formKey,
      autovalidateMode: widget.autoValidate
          ? AutovalidateMode.always
          : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Email',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          InputField(
            icon: FontAwesomeIcons.envelope,
            placeholder: 'Email',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập email';
              }
              if (!value.contains('@')) {
                return 'Email không hợp lệ';
              }
              return null;
            },
            onSaved: widget.onEmailSaved,
          ),
          const SizedBox(height: 10),
          const Text(
            'Mật khẩu',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          PasswordField(
            isVisible: widget.showPassword,
            onToggle: widget.toggleShowPassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu';
              }
              if (value.length < 6) {
                return 'Mật khẩu phải có ít nhất 6 ký tự';
              }
              return null;
            },
            onSaved: widget.onPasswordSaved,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                context.push('/send-email');
              },
              child: const Text(
                'Quên mật khẩu?',
                style: TextStyle(
                  color: Color(0xFF1167B1),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: widget.onLoginPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1167B1),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Đăng nhập',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
