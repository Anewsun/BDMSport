import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/input_field.dart';
import '../../../core/widgets/password_field.dart';
import '../../../core/widgets/social_login.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String email = '';
  String password = '';
  bool showPassword = false;

  void toggleShowPassword() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  void handleLogin(BuildContext context) {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'BDM SPORT',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Chào mừng bạn trở lại',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Đăng nhập để tiếp tục sử dụng ứng dụng của chúng tôi',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontFamily: 'Times New Roman',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              InputField(
                icon: FontAwesomeIcons.envelope,
                placeholder: 'Email',
                onChanged: (value) => setState(() => email = value),
              ),
              const SizedBox(height: 10),
              const Text(
                'Mật khẩu',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              PasswordField(
                value: password,
                isVisible: showPassword,
                onToggle: toggleShowPassword,
                onChanged: (v) => setState(() => password = v),
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
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: () => handleLogin(context),
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
              const SizedBox(height: 20),
              const Text(
                'HOẶC',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              SocialLogin(
                onGooglePress: () {
                  // TODO: Google login
                },
                onFacebookPress: () {
                  // TODO: Facebook login
                },
              ),
              const SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  text: 'Chưa có tài khoản? ',
                  style: const TextStyle(fontSize: 17, color: Colors.blueGrey),
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
          ),
        ),
      ),
    );
  }
}
