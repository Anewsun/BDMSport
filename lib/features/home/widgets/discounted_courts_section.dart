import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/court_model.dart';
import '../../../core/widgets/court_card.dart';

class DiscountedCourtsSection extends StatelessWidget {
  final List<Court> courts;
  final bool isDiscounted;
  final VoidCallback? onRetry;

  const DiscountedCourtsSection({
    super.key,
    required this.courts,
    this.isDiscounted = true,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey('courts-section-${courts.length}'),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(15, 25, 15, 10),
          alignment: Alignment.centerLeft,
          child: Text(
            isDiscounted ? 'Sân đang có giảm giá' : 'Các sân hiện có',
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

        if (courts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const Text(
                  'Không có dữ liệu để hiển thị',
                  style: TextStyle(fontSize: 16, color: Colors.lightBlue),
                ),
                if (onRetry != null)
                  TextButton(onPressed: onRetry, child: const Text('Thử lại')),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.6,
            ),
            itemCount: courts.length,
            itemBuilder: (context, index) {
              final court = courts[index];

              final map = <String, dynamic>{
                'name': court.name,
                'address': court.address,
                'featuredImageUrl': court.featuredImage,
                'rating': court.rating,
                'lowestPrice': court.lowestPrice,
                'lowestDiscountedPrice': court.lowestDiscountedPrice,
                'highestDiscountPercent': court.highestDiscountPercent,
              };

              return GestureDetector(
                onTap: () {
                  context.push('/court-detail/${court.id}');
                },
                child: CourtCard(
                  court: map,
                  showDiscountBadge:
                      isDiscounted && court.highestDiscountPercent > 0,
                ),
              );
            },
          ),
      ],
    );
  }
}
