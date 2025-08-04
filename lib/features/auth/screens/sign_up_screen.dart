import 'package:bdm_sport/core/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/input_field.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../controllers/sign_up_controller.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  String name = '';
  String email = '';
  String password = '';
  bool isPasswordVisible = false;
  bool isLoading = false;

  Future<void> _handleSignUp() async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    setState(() => isLoading = true);
    final controller = ref.read(signUpControllerProvider);
    await controller.signUp(
      context: context,
      name: name,
      email: email,
      password: password,
    );
    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: CustomHeader(title: 'Đăng ký', showBackIcon: false),
              ),
              const SizedBox(height: 30),
              const FaIcon(
                FontAwesomeIcons.warehouse,
                size: 100,
                color: Colors.blueAccent,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 500,
                        minHeight: screenHeight * 0.6,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InputField(
                            icon: FontAwesomeIcons.user,
                            placeholder: 'Họ và tên',
                            value: name,
                            onChanged: (v) => setState(() => name = v),
                          ),
                          const SizedBox(height: 10),
                          InputField(
                            icon: FontAwesomeIcons.envelope,
                            placeholder: 'Email',
                            value: email,
                            onChanged: (v) => setState(() => email = v),
                          ),
                          const SizedBox(height: 10),
                          PasswordField(
                            value: password,
                            isVisible: isPasswordVisible,
                            onToggle: () => setState(
                              () => isPasswordVisible = !isPasswordVisible,
                            ),
                            onChanged: (v) => setState(() => password = v),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: isLoading ? null : _handleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1167B1),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Đăng ký tài khoản',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
