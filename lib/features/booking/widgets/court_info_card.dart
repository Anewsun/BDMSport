import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';

class CourtInfoCard extends StatelessWidget {
  final Map<String, dynamic> courtData;
  final Map<String, dynamic> areaData;

  const CourtInfoCard({
    super.key,
    required this.courtData,
    required this.areaData,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 120,
          height: 120,
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
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 20, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    courtData['address'] ?? 'Địa chỉ',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.sports_tennis, size: 20, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Khu vực: ${areaData['name'] ?? 'Khu vực'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 20, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    '${formatPrice(areaData['price'] ?? 0)}/giờ',
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
