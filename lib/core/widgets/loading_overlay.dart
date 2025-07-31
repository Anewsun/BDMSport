import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.white.withOpacity(0.7),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xff1167B1)),
        ),
      ),
    );
  }
}
