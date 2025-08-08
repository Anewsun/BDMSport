import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class SortOptions extends StatelessWidget {
  final String? selectedSort;
  final Function(String) onSelect;
  final EdgeInsetsGeometry? containerMargin;
  final bool showAsModal;
  final VoidCallback? onClose;

  static const List<Map<String, String>> sortOptions = [
    {'label': 'Giá tăng dần', 'value': 'price'},
    {'label': 'Giá giảm dần', 'value': '-price'},
    {'label': 'Đánh giá thấp nhất', 'value': 'rating'},
    {'label': 'Đánh giá cao nhất', 'value': '-rating'},
    {'label': 'Giảm giá giảm dần', 'value': '-highestDiscountPercent'},
    {'label': 'Giảm giá tăng dần', 'value': 'highestDiscountPercent'},
  ];

  const SortOptions({
    super.key,
    this.selectedSort,
    required this.onSelect,
    this.containerMargin,
    this.showAsModal = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showAsModal) ...[
          const Text(
            "Sắp xếp theo",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
        ],
        Column(
          children: sortOptions.map((option) {
            final isSelected = selectedSort == option['value'];
            return GestureDetector(
              onTap: () => onSelect(option['value']!),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected
                      ? const Color(0xFFE3F2FD)
                      : Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      option['label']!,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (isSelected)
                      const Icon(
                        Ionicons.checkmark,
                        size: 20,
                        color: Color(0xFFFF385C),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (showAsModal) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: onClose,
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 18),
              foregroundColor: Colors.blue,
            ),
            child: const Text("Đóng"),
          ),
        ],
      ],
    );

    if (showAsModal) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        padding: const EdgeInsets.all(16),
        child: content,
      );
    }

    return Container(
      margin: containerMargin ?? const EdgeInsets.only(bottom: 16),
      child: content,
    );
  }
}
