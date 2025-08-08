import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InputField extends StatefulWidget {
  final String placeholder;
  final IconData icon;
  final Color? iconColor;
  final String? value;
  final Function(String)? onChanged;
  final Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final bool obscureText;

  const InputField({
    super.key,
    required this.placeholder,
    required this.icon,
    this.iconColor,
    this.value,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.obscureText = false,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _errorText != null ? Colors.red : Colors.black,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              FaIcon(widget.icon, size: 20, color: widget.iconColor ?? Colors.black),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: widget.value,
                  obscureText: widget.obscureText,
                  onChanged: (value) {
                    if (widget.onChanged != null) {
                      widget.onChanged!(value);
                    }
                    setState(() {
                      _errorText = widget.validator?.call(value);
                    });
                  },
                  onSaved: widget.onSaved,
                  validator: (value) {
                    final error = widget.validator?.call(value);
                    setState(() {
                      _errorText = error;
                    });
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: const TextStyle(color: Colors.black),
                    border: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    errorStyle: const TextStyle(height: 0),
                  ),
                  style: const TextStyle(color: Colors.black, fontSize: 17),
                ),
              ),
            ],
          ),
        ),
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              _errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
