import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InputField extends StatelessWidget {
  final String placeholder;
  final IconData icon;
  final String? value;
  final Function(String)? onChanged;
  final bool obscureText;

  const InputField({
    super.key,
    required this.placeholder,
    required this.icon,
    this.value,
    this.onChanged,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Row(
        children: [
          FaIcon(icon, size: 20, color: Colors.black),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              initialValue: value,
              obscureText: obscureText,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: const TextStyle(color: Colors.black),
                border: InputBorder.none,
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
