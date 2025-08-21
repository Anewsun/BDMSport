import 'package:flutter/material.dart';

class SpecialRequestsSection extends StatelessWidget {
  final bool earlyCheckIn;
  final bool lateCheckOut;
  final String specialRequests;
  final ValueChanged<bool> onEarlyCheckInChanged;
  final ValueChanged<bool> onLateCheckOutChanged;
  final ValueChanged<String> onSpecialRequestsChanged;

  const SpecialRequestsSection({
    super.key,
    required this.earlyCheckIn,
    required this.lateCheckOut,
    required this.specialRequests,
    required this.onEarlyCheckInChanged,
    required this.onLateCheckOutChanged,
    required this.onSpecialRequestsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Yêu cầu đặc biệt',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Đến sớm hơn'),
          value: earlyCheckIn,
          onChanged: onEarlyCheckInChanged,
          activeColor: Colors.blue,
        ),
        SwitchListTile(
          title: const Text('Ra về muộn hơn'),
          value: lateCheckOut,
          onChanged: onLateCheckOutChanged,
          activeColor: Colors.blue,
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: onSpecialRequestsChanged,
          decoration: const InputDecoration(
            labelText: 'Yêu cầu khác (nếu có)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}
