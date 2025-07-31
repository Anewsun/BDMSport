import 'package:flutter/material.dart';

class SocialLogin extends StatelessWidget {
  final VoidCallback? onGooglePress;
  final VoidCallback? onFacebookPress;

  const SocialLogin({super.key, this.onGooglePress, this.onFacebookPress});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(
          imagePath: 'assets/icons/google.png',
          label: 'Google',
          onPressed: onGooglePress,
        ),
        const SizedBox(width: 16),
        _buildButton(
          imagePath: 'assets/icons/facebook.png',
          label: 'Facebook',
          onPressed: onFacebookPress,
        ),
      ],
    );
  }

  Widget _buildButton({
    required String imagePath,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade400,
            width: 1.4,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 24, height: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
