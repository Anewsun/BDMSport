import 'package:bdm_sport/core/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/input_field.dart';
import '../../../core/widgets/custom_header.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String name = '';
  String email = '';
  String password = '';
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
                        InputField(
                          icon: FontAwesomeIcons.envelope,
                          placeholder: 'Email',
                          value: email,
                          onChanged: (v) => setState(() => email = v),
                        ),
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
                          onPressed: () {
                            // TODO: validate và gọi API đăng ký
                            context.go('/sign-in');
                          },
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
    );
  }
}
