import 'package:flutter/material.dart';
import 'package:bdm_sport/core/utils/formatters.dart';
import 'package:bdm_sport/core/utils/booking_status_utils.dart';
import 'detail_row_widget.dart';

class BookingInfoCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingInfoCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final checkIn = booking['checkIn'] as DateTime;
    final checkOut = booking['checkOut'] as DateTime;

    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin đặt sân',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003366),
              ),
            ),
            const SizedBox(height: 12),
            DetailRowWidget(
              icon: Icons.sports_tennis,
              label: 'Tên sân',
              value: booking['area']['name'] ?? 'Không có thông tin',
            ),
            DetailRowWidget(
              icon: Icons.calendar_today,
              label: 'Ngày đặt',
              value: formatDate(checkIn),
            ),
            DetailRowWidget(
              icon: Icons.access_time,
              label: 'Giờ chơi',
              value: '${formatTime(checkIn)} - ${formatTime(checkOut)}',
            ),
            DetailRowWidget(
              icon: Icons.timer,
              label: 'Thời lượng',
              value: formatDuration(checkIn, checkOut),
            ),
            DetailRowWidget(
              icon: Icons.info,
              label: 'Trạng thái',
              value: BookingStatusUtils.getStatusText(booking['status']),
              valueColor: BookingStatusUtils.getStatusColor(booking['status']),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerInfoCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const CustomerInfoCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin người đặt',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003366),
              ),
            ),
            const SizedBox(height: 12),
            DetailRowWidget(
              icon: Icons.person,
              label: 'Họ tên',
              value: booking['contactInfo']?['name'] ?? 'Không có thông tin',
            ),
            DetailRowWidget(
              icon: Icons.phone,
              label: 'Điện thoại',
              value: booking['contactInfo']?['phone'] ?? 'Không có thông tin',
            ),
            DetailRowWidget(
              icon: Icons.info,
              label: 'Loại đặt sân',
              value: booking['bookingFor'] == 'self'
                  ? 'Tự đặt cho mình'
                  : 'Đặt cho người khác',
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentInfoCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const PaymentInfoCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin thanh toán',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003366),
              ),
            ),
            const SizedBox(height: 12),
            DetailRowWidget(
              icon: Icons.attach_money,
              label: 'Tổng tiền',
              value: formatPrice(booking['finalPrice'] ?? 0),
              valueStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            DetailRowWidget(
              icon: Icons.payment,
              label: 'Phương thức',
              value: booking['paymentMethod'] == 'cash'
                  ? 'Tiền mặt'
                  : 'Chuyển khoản',
            ),
            DetailRowWidget(
              icon: Icons.info,
              label: 'Trạng thái',
              value: booking['paymentStatus'] == 'paid'
                  ? 'Đã thanh toán'
                  : booking['paymentStatus'] == 'pending'
                  ? 'Chờ thanh toán'
                  : 'Đã hủy',
              valueColor: booking['paymentStatus'] == 'paid'
                  ? Colors.green
                  : booking['paymentStatus'] == 'pending'
                  ? Colors.amber
                  : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class SpecialRequestsCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const SpecialRequestsCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    if (booking['specialRequests'] == null) return const SizedBox.shrink();

    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Yêu cầu đặc biệt',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003366),
              ),
            ),
            const SizedBox(height: 12),
            DetailRowWidget(
              icon: Icons.note,
              label: 'Ghi chú',
              value:
                  booking['specialRequests']['additionalRequests'] ??
                  'Không có yêu cầu đặc biệt',
            ),
          ],
        ),
      ),
    );
  }
}
