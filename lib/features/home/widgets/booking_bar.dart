import 'package:flutter/material.dart';
import '../../../core/models/area_model.dart';
import '../../../core/utils/formatters.dart';

class BookingBar extends StatelessWidget {
  final List<Area> areas;
  final int? selectedAreaIndex;
  final VoidCallback onBookPressed;
  final bool isEnabled;

  const BookingBar({
    super.key,
    required this.areas,
    required this.selectedAreaIndex,
    required this.onBookPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelectedArea =
        selectedAreaIndex != null && selectedAreaIndex! < areas.length;
    final selectedArea = hasSelectedArea ? areas[selectedAreaIndex!] : null;
    final hasDiscount =
        selectedArea != null && selectedArea.discountPercent > 0;
    final isButtonEnabled = isEnabled && hasSelectedArea;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Giá sân',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (hasSelectedArea)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasDiscount)
                        Text(
                          '${formatPrice(selectedArea.price)}/giờ',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      Text(
                        '${formatPrice(hasDiscount ? selectedArea.discountedPrice : selectedArea!.price)}/giờ',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                if (!hasSelectedArea)
                  const Text(
                    'Vui lòng chọn sân',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isButtonEnabled
                  ? const Color(0xFF1167B1)
                  : Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: isButtonEnabled ? onBookPressed : null,
            child: const Text(
              'Đặt sân ngay',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
