import 'package:intl/intl.dart';

// Định dạng giá tiền: 500000 => "500.000 VNĐ"
String formatPrice(num price) {
  final formatter = NumberFormat.decimalPattern('vi_VN');
  return '${formatter.format(price)} VNĐ';
}

// Định dạng ngày: "2025-12-01T00:00:00Z" => "01/12/2025"
String formatDate(DateTime? date) {
  if (date == null) return '--/--/----';
  return DateFormat('dd/MM/yyyy').format(date);
}

// Định dạng giờ: "2025-12-01T17:30:00Z" => "17:30"
String formatTime(dynamic dateTime) {
  try {
    DateTime date;

    if (dateTime == null) return '--:--';
    if (dateTime is DateTime) {
      date = dateTime;
    } else if (dateTime is String) {
      date = DateTime.parse(dateTime);
    } else {
      return '--:--';
    }

    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  } catch (e) {
    return '--:--';
  }
}
