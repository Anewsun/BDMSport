import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
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

    handleAuthAction(() async {
      final controller = ref.read(signInControllerProvider.notifier);
      return await controller.login(email, password);
    });
  }

  Future<void> handleAuthAction(Future<bool> Function() authFunction) async {
    try {
      final success = await authFunction();

      if (!mounted) return;

      if (success) {
        GoRouter.of(context).go('/home?loginSuccess=true');
      } else {
        final currentError = ref.read(signInControllerProvider).error;
        Fluttertoast.showToast(
          msg: getFriendlyErrorMessage(currentError ?? "Đăng nhập thất bại"),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e, st) {
      print('==> Error in auth action: $e');
      print(st);

      Fluttertoast.showToast(
        msg: getFriendlyErrorMessage(e),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      ref.read(signInControllerProvider.notifier).setLoading(false);
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
                  handleAuthAction(
                    () => ref
                        .read(signInControllerProvider.notifier)
                        .loginWithGoogle(),
                  );
                },
                onFacebookPress: () {
                  handleAuthAction(
                    () => ref
                        .read(signInControllerProvider.notifier)
                        .loginWithFacebook(),
                  );
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
