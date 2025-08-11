import 'package:flutter/material.dart';
import 'package:bdm_sport/core/widgets/date_time_picker_row.dart';
import 'package:bdm_sport/core/widgets/search_box_container.dart';

class AreaSearchBox extends StatefulWidget {
  const AreaSearchBox({super.key});

  @override
  State<AreaSearchBox> createState() => _AreaSearchBoxState();
}

class _AreaSearchBoxState extends State<AreaSearchBox> {
  DateTime checkInDate = DateTime.now();
  DateTime checkOutDate = DateTime.now().add(const Duration(days: 1));

  void _openDatePicker(bool isCheckIn) async {
    DateTime initialDate = isCheckIn ? checkInDate : checkOutDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      helpText: isCheckIn ? 'Chọn ngày nhận sân' : 'Chọn ngày trả sân',
      locale: const Locale('vi'),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          checkInDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            checkInDate.hour,
            checkInDate.minute,
          );
          if (checkOutDate.isBefore(checkInDate) ||
              checkOutDate.isAtSameMomentAs(checkInDate)) {
            checkOutDate = checkInDate.add(const Duration(hours: 1));
          }
        } else {
          checkOutDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            checkOutDate.hour,
            checkOutDate.minute,
          );
        }
      });
    }
  }

  void _openTimePicker(bool isCheckIn) async {
    final initialTime = TimeOfDay.fromDateTime(
      isCheckIn ? checkInDate : checkOutDate,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: isCheckIn ? 'Chọn giờ nhận sân' : 'Chọn giờ trả sân',
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          checkInDate = DateTime(
            checkInDate.year,
            checkInDate.month,
            checkInDate.day,
            picked.hour,
            picked.minute,
          );
          if (checkOutDate.isBefore(checkInDate) ||
              checkOutDate.isAtSameMomentAs(checkInDate)) {
            checkOutDate = checkInDate.add(const Duration(hours: 1));
          }
        } else {
          checkOutDate = DateTime(
            checkOutDate.year,
            checkOutDate.month,
            checkOutDate.day,
            picked.hour,
            picked.minute,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SearchBoxContainer(
      children: [
        DateTimePickerRow(
          label: "Nhận sân",
          dateTime: checkInDate,
          onDateTap: () => _openDatePicker(true),
          onTimeTap: () => _openTimePicker(true),
        ),
        const SizedBox(height: 16),
        DateTimePickerRow(
          label: "Trả sân",
          dateTime: checkOutDate,
          onDateTap: () => _openDatePicker(false),
          onTimeTap: () => _openTimePicker(false),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            debugPrint('Nhận sân: ${checkInDate.toString()}');
            debugPrint('Trả sân: ${checkOutDate.toString()}');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1167B1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            minimumSize: const Size(double.infinity, 0),
          ),
          child: const Text(
            'Tìm kiếm',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
