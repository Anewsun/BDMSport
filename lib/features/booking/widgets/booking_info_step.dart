import 'package:flutter/material.dart';
import '../../../core/widgets/date_time_picker_row.dart';
import 'court_info_card.dart';
import 'special_requests_section.dart';

class BookingInfoStep extends StatelessWidget {
  final Map<String, dynamic> courtData;
  final Map<String, dynamic> areaData;
  final DateTime startTime;
  final DateTime endTime;
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;
  final bool earlyCheckIn;
  final bool lateCheckOut;
  final String specialRequests;
  final VoidCallback onStartTimeTap;
  final VoidCallback onEndTimeTap;
  final ValueChanged<bool> onEarlyCheckInChanged;
  final ValueChanged<bool> onLateCheckOutChanged;
  final ValueChanged<String> onSpecialRequestsChanged;

  const BookingInfoStep({
    super.key,
    required this.courtData,
    required this.areaData,
    required this.startTime,
    required this.endTime,
    required this.startTimeController,
    required this.endTimeController,
    required this.earlyCheckIn,
    required this.lateCheckOut,
    required this.specialRequests,
    required this.onStartTimeTap,
    required this.onEndTimeTap,
    required this.onEarlyCheckInChanged,
    required this.onLateCheckOutChanged,
    required this.onSpecialRequestsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CourtInfoCard(courtData: courtData, areaData: areaData),
          const SizedBox(height: 24),
          DateTimePickerRow(
            label: 'Thời gian bắt đầu',
            dateTime: startTime,
            onDateTap: onStartTimeTap,
            onTimeTap: onStartTimeTap,
          ),
          const SizedBox(height: 16),
          DateTimePickerRow(
            label: 'Thời gian kết thúc',
            dateTime: endTime,
            onDateTap: onEndTimeTap,
            onTimeTap: onEndTimeTap,
          ),
          SpecialRequestsSection(
            earlyCheckIn: earlyCheckIn,
            lateCheckOut: lateCheckOut,
            specialRequests: specialRequests,
            onEarlyCheckInChanged: onEarlyCheckInChanged,
            onLateCheckOutChanged: onLateCheckOutChanged,
            onSpecialRequestsChanged: onSpecialRequestsChanged,
          ),
        ],
      ),
    );
  }
}
