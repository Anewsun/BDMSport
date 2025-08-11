import 'package:flutter/material.dart';

class PoliciesSection extends StatelessWidget {
  final Map<String, dynamic> policies;

  const PoliciesSection({super.key, required this.policies});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chính sách',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1.5),
            },
            border: TableBorder.symmetric(
              inside: BorderSide(color: Colors.grey.shade300),
            ),
            children: [
              _buildPolicyRow('Giờ mở cửa', policies['checkInTime']),
              _buildPolicyRow('Giờ đóng cửa', policies['checkOutTime']),
              _buildPolicyRow('Trẻ em', policies['childrenPolicy']),
              _buildPolicyRow('Thú cưng', policies['petPolicy']),
              _buildPolicyRow('Hút thuốc', policies['smokingPolicy']),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _buildPolicyRow(String label, String value) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.white),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          color: const Color(0xFF1a73e8),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          color: const Color(0xFF8ab4f8),
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1a73e8),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
