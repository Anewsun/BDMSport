import 'package:bdm_sport/core/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:bdm_sport/core/widgets/date_time_picker_row.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class SearchBox extends StatefulWidget {
  const SearchBox({super.key});

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final TextEditingController locationController = TextEditingController();
  DateTime checkInDate = DateTime.now();
  DateTime checkOutDate = DateTime.now();

  void openDatePicker(bool isCheckIn) async {
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

  void openTimePicker(bool isCheckIn) async {
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
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Địa điểm",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Times New Roman',
                ),
              ),
            ),
            const SizedBox(height: 8),
            InputField(
              icon: FontAwesomeIcons.locationDot,
              iconColor: Colors.blue,
              placeholder: 'Nhập tên, địa điểm',
            ),
            const SizedBox(height: 16),
            DateTimePickerRow(
              label: "Thời điểm nhận sân",
              dateTime: checkInDate,
              onDateTap: () => openDatePicker(true),
              onTimeTap: () => openTimePicker(true),
            ),
            const SizedBox(height: 16),

            DateTimePickerRow(
              label: "Thời điểm trả sân",
              dateTime: checkOutDate,
              onDateTap: () => openDatePicker(false),
              onTimeTap: () => openTimePicker(false),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                context.push('/search-results');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1167B1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Center(
                child: Text(
                  'Tìm kiếm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
