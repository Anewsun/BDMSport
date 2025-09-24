import 'package:flutter/material.dart';

class SearchBoxContainer extends StatelessWidget {
  final List<Widget> children;

  const SearchBoxContainer({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(15),
      clipBehavior: Clip.none,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
