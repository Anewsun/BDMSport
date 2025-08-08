import 'dart:math';
import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final int maxVisiblePages = 5;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (currentPage > 1)
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => onPageChanged(currentPage - 1),
            ),

          if (currentPage > (maxVisiblePages ~/ 2) + 1) _buildPageItem(1),
          if (currentPage > (maxVisiblePages ~/ 2) + 2) const Text('...'),

          ..._generateVisiblePages().map((page) => _buildPageItem(page)),

          if (currentPage < totalPages - (maxVisiblePages ~/ 2) - 1)
            const Text('...'),
          if (currentPage < totalPages - (maxVisiblePages ~/ 2))
            _buildPageItem(totalPages),

          if (currentPage < totalPages)
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => onPageChanged(currentPage + 1),
            ),
        ],
      ),
    );
  }

  List<int> _generateVisiblePages() {
    final List<int> pages = [];
    final int half = maxVisiblePages ~/ 2;
    int start = currentPage - half;
    int end = currentPage + half;

    if (start < 1) {
      start = 1;
      end = maxVisiblePages;
    }

    if (end > totalPages) {
      end = totalPages;
      start = max(1, end - maxVisiblePages + 1);
    }

    for (int i = start; i <= end; i++) {
      pages.add(i);
    }

    return pages;
  }

  Widget _buildPageItem(int pageNumber) {
    return GestureDetector(
      onTap: () => onPageChanged(pageNumber),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: currentPage == pageNumber
              ? const Color(0xFF1167B1)
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          pageNumber.toString(),
          style: TextStyle(
            color: currentPage == pageNumber ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
