import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final String? value;
  final Function(String)? onChanged;
  final bool isVisible;
  final VoidCallback onToggle;
  final String hintText;
  final String? Function(String?)? validator;
  final Function(String?)? onSaved;

  const PasswordField({
    super.key,
    this.value,
    this.onChanged,
    required this.isVisible,
    required this.onToggle,
    this.hintText = 'Mật khẩu',
    this.validator,
    this.onSaved,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            border: Border.all(
              color: _errorText != null ? Colors.red : Colors.black,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.onToggle,
                child: Icon(
                  widget.isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: widget.value,
                  obscureText: !widget.isVisible,
                  onChanged: (value) {
                    if (widget.onChanged != null) {
                      widget.onChanged!(value);
                    }
                    setState(() {
                      _errorText = widget.validator?.call(value);
                    });
                  },
                  validator: (value) {
                    final error = widget.validator?.call(value);
                    setState(() {
                      _errorText = error;
                    });
                    return null;
                  },
                  onSaved: widget.onSaved,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    border: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    errorStyle: const TextStyle(height: 0),
                    hintStyle: const TextStyle(
                      color: Colors.black,
                      fontFamily: 'Times New Roman',
                    ),
                  ),
                  style: const TextStyle(color: Colors.black, fontSize: 18),
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
