import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;

class MarkAllAsReadButton extends StatelessWidget {
  final VoidCallback onPressed;

  const MarkAllAsReadButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: material.IconButton(
          icon: const Icon(Icons.done_all, color: Colors.blue, size: 24),
          onPressed: onPressed,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
      ),
    );
  }
}
