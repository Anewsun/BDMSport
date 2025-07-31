import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';

class TierSection extends StatelessWidget {
  final String tier;
  final int balance;

  const TierSection({super.key, required this.tier, required this.balance});

  Color getTierColor() {
    switch (tier) {
      case 'Gold':
        return Colors.amber;
      case 'Silver':
        return Colors.grey;
      default:
        return const Color(0xffcd7f32);
    }
  }

  String getTierIcon() {
    switch (tier) {
      case 'Gold':
        return '🥇';
      case 'Silver':
        return '🥈';
      default:
        return '🥉';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(getTierIcon(), style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            tier,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xff1167B1),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tier == 'Gold'
                ? 'Hạng thành viên cao nhất với nhiều ưu đãi'
                : tier == 'Silver'
                ? 'Hạng thành viên trung cấp với ưu đãi tốt'
                : 'Hạng thành viên cơ bản',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Số dư tài khoản: ${formatPrice(balance)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
