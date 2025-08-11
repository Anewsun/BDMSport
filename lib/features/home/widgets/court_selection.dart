import 'package:flutter/material.dart';

class CourtSelection extends StatefulWidget {
  final List<Map<String, dynamic>> courts;
  final bool showAllReviews;
  final VoidCallback onToggleReviews;
  final VoidCallback onEditReview;
  final VoidCallback onDeleteReview;
  final ValueChanged<int?> onCourtSelected;

  const CourtSelection({
    super.key,
    required this.courts,
    required this.showAllReviews,
    required this.onToggleReviews,
    required this.onEditReview,
    required this.onDeleteReview,
    required this.onCourtSelected,
  });

  @override
  State<CourtSelection> createState() => _CourtSelectionState();
}

class _CourtSelectionState extends State<CourtSelection> {
  int? selectedCourtIndex;
  List<int> expandedCourts = [];
  bool showAllCourts = false;
  int initialCourtCount = 2;

  @override
  Widget build(BuildContext context) {
    final displayedCourts = showAllCourts
        ? widget.courts
        : widget.courts.take(initialCourtCount).toList();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Chọn sân',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          if (displayedCourts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Không có sân nào',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          else
            ...displayedCourts.asMap().entries.map(
              (entry) => _buildCourtCard(entry.value, entry.key),
            ),

          if (widget.courts.length > initialCourtCount)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                onPressed: () {
                  setState(() {
                    showAllCourts = !showAllCourts;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      showAllCourts
                          ? 'Thu gọn'
                          : 'Xem thêm (${widget.courts.length - initialCourtCount})',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      showAllCourts
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.black,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCourtCard(Map<String, dynamic> court, int index) {
    final isSelected = selectedCourtIndex == index;
    final isExpanded = expandedCourts.contains(index);
    final hasDiscount =
        court['discountedPrice'] != null &&
        court['discountedPrice'] < court['price'];

    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey[300]!,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            if (isExpanded) {
              expandedCourts.remove(index);
            } else {
              expandedCourts.add(index);
            }
          });
        },
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: court['images'].length,
                itemBuilder: (context, imgIndex) {
                  return ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.asset(
                      court['images'][imgIndex],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        court['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                        ),
                        onPressed: () {
                          setState(() {
                            if (isExpanded) {
                              expandedCourts.remove(index);
                            } else {
                              expandedCourts.add(index);
                            }
                          });
                        },
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      if (hasDiscount)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${court['price'].toStringAsFixed(0)} VNĐ',
                            style: const TextStyle(
                              fontSize: 17,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: hasDiscount ? Colors.red[50] : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hasDiscount
                              ? '${court['discountedPrice'].toStringAsFixed(0)} VNĐ/giờ'
                              : '${court['price'].toStringAsFixed(0)} VNĐ/giờ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: hasDiscount ? Colors.red : Colors.blue,
                          ),
                        ),
                      ),
                      if (hasDiscount)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '-${court['discountPercent']}%',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            if (isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (court['description'] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          court['description'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),

                    _buildDetailRow(
                      Icons.aspect_ratio,
                      'Kích thước: ${court['size']}',
                    ),
                    _buildDetailRow(
                      Icons.category,
                      'Loại sân: ${court['type']}',
                    ),
                    _buildDetailRow(
                      Icons.lightbulb,
                      'Hệ thống chiếu sáng: ${court['lighting']}',
                    ),

                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? Colors.blue
                              : Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedCourtIndex = isSelected ? null : index;
                          });
                          if (isSelected) {
                            widget.onCourtSelected(null);
                          } else {
                            widget.onCourtSelected(index);
                          }
                        },
                        child: Icon(
                          isSelected ? Icons.check_circle : Icons.add_circle,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 15, color: Colors.black)),
        ],
      ),
    );
  }
}
