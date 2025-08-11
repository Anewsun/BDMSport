import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/court_card.dart';
import '../../../core/widgets/pagination_controls.dart';

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
                  color: Color.fromRGBO(0, 0, 0, 0.8),
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
                onTap: () {
                  context.push('/court-detail');
                },
                isFavorite: false,
                onToggleFavorite: () {},
                showDiscountBadge: true,
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        PaginationControls(
          currentPage: currentPage,
          totalPages: totalPages,
          onPageChanged: onPageChanged,
        ),
        const SizedBox(height: 60),
      ],
    );
  }
}
