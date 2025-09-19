import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/amenity_icons.dart';
import '../../../core/models/area_model.dart';

class CourtSelection extends StatefulWidget {
  final List<Area> areas;
  final bool showAllReviews;
  final VoidCallback onToggleReviews;
  final VoidCallback onEditReview;
  final VoidCallback onDeleteReview;
  final ValueChanged<int?> onCourtSelected;

  const CourtSelection({
    super.key,
    required this.areas,
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
    final displayedAreas = showAllCourts
        ? widget.areas
        : widget.areas.take(initialCourtCount).toList();

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

          if (displayedAreas.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Không có sân nào',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          else
            ...displayedAreas.asMap().entries.map(
              (entry) => _buildCourtCard(entry.value, entry.key),
            ),

          if (widget.areas.length > initialCourtCount)
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
                          : 'Xem thêm (${widget.areas.length - initialCourtCount})',
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

  Widget _buildCourtCard(Area area, int index) {
    final isSelected = selectedCourtIndex == index;
    final isExpanded = expandedCourts.contains(index);
    final hasDiscount = area.discountPercent > 0;

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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                area.image,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.error, color: Colors.grey),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
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
                      Expanded(
                        child: Text(
                          area.nameArea,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                            formatPrice(area.price),
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
                              ? '${formatPrice(area.discountedPrice)}/giờ'
                              : '${formatPrice(area.price)}/giờ',
                          style: TextStyle(
                            fontSize: 16,
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
                            '-${area.discountPercent}%',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.brown,
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
                    if (area.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          area.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    _buildDetailRow(
                      Icons.sports_tennis_rounded,
                      'Loại sân: ${area.courtType}',
                    ),

                    if (area.amenities.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tiện nghi:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: area.amenities
                                  .map((amenity) => _buildAmenityChip(amenity))
                                  .toList(),
                            ),
                          ],
                        ),
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
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.black),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(String amenityName) {
    final amenityIcon = getAmenityIcon(amenityName);

    return Chip(
      label: Text(amenityIcon.vietnameseName, style: const TextStyle(fontSize: 15)),
      avatar: Icon(amenityIcon.icon, size: 18, color: amenityIcon.color),
      backgroundColor: Colors.grey[100],
      visualDensity: VisualDensity.compact,
    );
  }
}
