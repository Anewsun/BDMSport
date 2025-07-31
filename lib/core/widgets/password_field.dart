import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  final String? value;
  final Function(String)? onChanged;
  final bool isVisible;
  final VoidCallback onToggle;
  final String hintText;

  const PasswordField({
    super.key,
    this.value,
    this.onChanged,
    required this.isVisible,
    required this.onToggle,
    this.hintText = 'Mật khẩu', // mặc định nếu không truyền
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              initialValue: value,
              obscureText: !isVisible,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Colors.black, fontFamily: 'Times New Roman'),
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
