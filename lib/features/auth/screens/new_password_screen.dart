import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/password_field.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const NewPasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  String _password = '';
  String _confirmPassword = '';
  bool showPassword = false;
  bool showConfirmPassword = false;

  void handleCreatePassword() {
    if (_password != _confirmPassword) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Chú ý'),
          content: Text('Mật khẩu phải giống nhau.'),
        ),
      );
      return;
    }

    if (_password.length < 6) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Chú ý'),
          content: Text('Mật khẩu ít nhất 6 ký tự.'),
        ),
      );
      return;
    }

    // TODO: Gọi API reset password với widget.email, widget.otp, _password
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thành công'),
        content: const Text('Mật khẩu đã được đặt lại.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/sign-in');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomHeader(
                title: 'Đổi mật khẩu',
                showBackIcon: true,
                onBackPress: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 20),
            const FaIcon(
              FontAwesomeIcons.lock,
              size: 90,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 500,
                      minHeight: screenHeight * 0.5,
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Mật khẩu mới phải khác với mật khẩu trước đó.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),

                        PasswordField(
                          value: _password,
                          isVisible: showPassword,
                          hintText: 'Mật khẩu mới',
                          onChanged: (val) => setState(() => _password = val),
                          onToggle: () =>
                              setState(() => showPassword = !showPassword),
                        ),

                        PasswordField(
                          value: _confirmPassword,
                          isVisible: showConfirmPassword,
                          hintText: 'Xác nhận mật khẩu',
                          onChanged: (val) =>
                              setState(() => _confirmPassword = val),
                          onToggle: () => setState(
                            () => showConfirmPassword = !showConfirmPassword,
                          ),
                        ),

                        const SizedBox(height: 30),

                        ElevatedButton(
                          onPressed: handleCreatePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1167B1),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Tạo mật khẩu mới',
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
