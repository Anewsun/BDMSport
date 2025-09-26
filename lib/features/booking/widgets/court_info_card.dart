import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';

class CourtInfoCard extends StatelessWidget {
  final Map<String, dynamic> courtData;
  final Map<String, dynamic> areaData;
  final double? originalPrice;
  final double? finalPrice;
  final bool showPriceComparison;

  const CourtInfoCard({
    super.key,
    required this.courtData,
    required this.areaData,
    this.originalPrice,
    this.finalPrice,
    this.showPriceComparison = false,
  });

  @override
  Widget build(BuildContext context) {
    final double basePrice = (areaData['price'] as num?)?.toDouble() ?? 0.0;
    final double displayOriginalPrice = originalPrice ?? basePrice;
    final double displayFinalPrice = finalPrice ?? basePrice;
    final bool hasDiscount =
        showPriceComparison && displayFinalPrice < displayOriginalPrice;

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: areaData['imageUrl'] != null
                      ? NetworkImage(areaData['imageUrl'] as String)
                      : const AssetImage('assets/images/court1.jpg')
                            as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courtData['name'] ?? 'Sân cầu lông',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.location_on,
                    courtData['address'] ?? 'Địa chỉ',
                  ),
                  _buildInfoRow(
                    Icons.sports_tennis,
                    'Khu vực: ${areaData['name'] ?? 'Khu vực'}',
                  ),
                  const SizedBox(height: 8),
                  if (hasDiscount) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          size: 20,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${formatPrice(displayOriginalPrice)}/giờ',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 20,
                        color: hasDiscount ? Colors.red : Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${formatPrice(displayFinalPrice)}/giờ',
                        style: TextStyle(
                          fontSize: 16,
                          color: hasDiscount ? Colors.red : Colors.blue,
                          fontWeight: hasDiscount
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
