import 'package:flutter/material.dart';
import '../../../core/widgets/court_card.dart';

class DiscountedCourtsSection extends StatelessWidget {
  final List<Map<String, dynamic>> courts;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const DiscountedCourtsSection({
    super.key,
    required this.courts,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final paginatedCourts = courts.skip((currentPage - 1) * 6).take(6).toList();

    return Column(
      children: [
        Container(
          color: Colors.black.withOpacity(0.02),
          padding: const EdgeInsets.fromLTRB(15, 25, 15, 10),
          child: Text(
            'Sân đang có giảm giá',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Times New Roman',
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [Colors.red, Colors.yellow, Colors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(const Rect.fromLTWH(0, 0, 250, 40)),
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.6),
                  offset: const Offset(1, 1),
                ),
                Shadow(blurRadius: 10, color: Colors.red, offset: Offset.zero),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: paginatedCourts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.55,
            ),
            itemBuilder: (_, index) {
              final court = paginatedCourts[index];
              return CourtCard(
                court: court,
                onTap: () {},
                isFavorite: false,
                onToggleFavorite: () {},
                showDiscountBadge: true,
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            totalPages,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentPage == index + 1
                      ? const Color(0xFF1167B1)
                      : Colors.grey,
                ),
                onPressed: () {
                  onPageChanged(index + 1);
                },
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontFamily: 'Times New Roman',
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}
