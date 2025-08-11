import 'package:flutter/material.dart';

class ReviewsSection extends StatelessWidget {
  final List<Map<String, dynamic>> reviews;
  final bool showAllReviews;
  final VoidCallback onToggleReviews;
  final VoidCallback onEditReview;
  final VoidCallback onDeleteReview;

  const ReviewsSection({
    super.key,
    required this.reviews,
    required this.showAllReviews,
    required this.onToggleReviews,
    required this.onEditReview,
    required this.onDeleteReview,
  });

  @override
  Widget build(BuildContext context) {
    final totalReviews = reviews.length;
    final averageRating = reviews.isEmpty
        ? 0.0
        : reviews.map((r) => r['rating']).reduce((a, b) => a + b) /
              totalReviews;
    final initialReviewCount = 2;
    final displayedReviews = showAllReviews
        ? reviews
        : reviews.take(initialReviewCount).toList();

    final starCounts = List.generate(5, (index) {
      return reviews.where((r) => r['rating'] == index + 1).length;
    });

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đánh giá',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (reviews.isEmpty)
            const Center(
              child: Text(
                'Chưa có bài đánh giá nào',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Text(
                      '⭐${averageRating.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$totalReviews bài đánh giá',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),

                Expanded(
                  child: Column(
                    children: List.generate(5, (index) {
                      final proportion = starCounts[index] / totalReviews;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          children: [
                            Text(
                              '${index + 1} ⭐',
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: proportion,
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation(
                                  Colors.amber,
                                ),
                                minHeight: 10,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${starCounts[index]}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Column(
              children: displayedReviews.map((review) {
                return _buildReviewItem(review);
              }).toList(),
            ),

            if (totalReviews > initialReviewCount)
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: onToggleReviews,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        showAllReviews
                            ? 'Thu gọn'
                            : 'Xem thêm ${totalReviews - initialReviewCount} đánh giá',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        showAllReviews
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: review['isAnonymous']
                      ? const AssetImage('assets/images/anonymous.png')
                      : (review['userImage'] != null &&
                                review['userImage'].isNotEmpty
                            ? (review['userImage'].startsWith('http')
                                  ? NetworkImage(review['userImage'])
                                  : AssetImage(review['userImage']))
                            : const AssetImage(
                                'assets/images/default-avatar.jpg',
                              )),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            review['isAnonymous']
                                ? 'Ẩn danh'
                                : review['userName'] ?? 'Khách',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (review['isOwner'] ?? false)
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  onPressed: onEditReview,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  onPressed: onDeleteReview,
                                ),
                              ],
                            ),
                        ],
                      ),
                      Text(
                        review['date'] ?? '01/01/2025',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              review['title'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),

            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < (review['rating'] ?? 0)
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
            const SizedBox(height: 8),

            Text(
              review['comment'] ?? '',
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
            const SizedBox(height: 8),

            if (review['images'] != null && review['images'].isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review['images'].length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          review['images'][index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
