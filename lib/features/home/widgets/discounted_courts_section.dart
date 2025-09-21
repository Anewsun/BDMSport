import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/court_model.dart';
import '../../../core/widgets/court_card.dart';
import '../../../core/controllers/favorite_controller.dart';

class DiscountedCourtsSection extends ConsumerWidget {
  final List<Court> courts;
  final bool isDiscounted;
  final VoidCallback? onRetry;
  final String? userId;
  final Function(String)? onToggleFavorite;

  const DiscountedCourtsSection({
    super.key,
    required this.courts,
    this.isDiscounted = true,
    this.onRetry,
    this.userId,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteCourtIdsAsync = userId != null
        ? ref.watch(favoriteCourtIdsProvider(userId!))
        : const AsyncValue.data([]);

    return Column(
      key: ValueKey(
        'courts-section-${courts.length}-${DateTime.now().millisecondsSinceEpoch}',
      ),
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
          favoriteCourtIdsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Lỗi: $error')),
            data: (favoriteCourtIds) {
              return GridView.builder(
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
                  final isFavorite = favoriteCourtIds.contains(court.id);

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
                      isFavorite: isFavorite,
                      onToggleFavorite: userId != null
                          ? () => onToggleFavorite?.call(court.id)
                          : null,
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}
