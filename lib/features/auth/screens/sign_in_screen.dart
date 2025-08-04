import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/utils/error_util.dart';
import '../controllers/sign_in_controller.dart';
import '../widgets/sign_in_divider.dart';
import '../widgets/sign_in_footer.dart';
import '../widgets/sign_in_form.dart';
import '../widgets/sign_in_header.dart';
import '../../../core/widgets/social_login.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool showPassword = false;
  bool _autoValidate = false;

  void toggleShowPassword() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  Future<void> handleLogin() async {
    setState(() => _autoValidate = true);

    if (!_formKey.currentState!.validate()) {
      if (email.isEmpty || password.isEmpty) {
        Fluttertoast.showToast(
          msg: "Vui lòng nhập email và mật khẩu",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
      return;
    }

    _formKey.currentState?.save();

    final controller = ref.read(signInControllerProvider);
    final success = await controller.login(email, password);

    if (success && mounted) {
      context.go('/home');
    } else if (!success && mounted) {
      final error = controller.error;
      if (error != null) {
        if (error.code == 'email-not-verified') {
          ref.read(authProvider.notifier).setLoading(false);

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Email chưa xác nhận'),
              content: Text(
                'Bạn cần xác nhận email trước khi đăng nhập. '
                'Vui lòng kiểm tra hộp thư $email và làm theo hướng dẫn.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _formKey.currentState?.reset();
                    setState(() {
                      email = '';
                      password = '';
                      _autoValidate = false;
                    });
                  },
                  child: const Text('Đóng'),
                ),
              ],
            ),
          );
        } else {
          Fluttertoast.showToast(
            msg: getFriendlyErrorMessage(error),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SignInHeader(),
              SignInForm(
                formKey: _formKey,
                autoValidate: _autoValidate,
                onEmailSaved: (value) => email = value ?? '',
                onPasswordSaved: (value) => password = value ?? '',
                onLoginPressed: handleLogin,
                toggleShowPassword: toggleShowPassword,
                showPassword: showPassword,
              ),
              const SignInDivider(),
              SocialLogin(
                onGooglePress: () {
                  // TODO: Google login
                },
                onFacebookPress: () {
                  // TODO: Facebook login
                },
              ),
              const SignInFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
