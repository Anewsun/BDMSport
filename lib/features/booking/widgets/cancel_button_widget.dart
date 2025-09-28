import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/controllers/booking_controller.dart';

class CancelButtonWidget extends StatelessWidget {
  final VoidCallback onCancel;
  final String bookingStatus;
  final String bookingId;
  final DateTime checkInTime;

  const CancelButtonWidget({
    super.key,
    required this.onCancel,
    required this.bookingStatus,
    required this.bookingId,
    required this.checkInTime,
  });

  bool get _canCancelBooking {
    final now = DateTime.now();
    final timeDifference = checkInTime.difference(now);
    return timeDifference.inMinutes >= 30;
  }

  void _handleCancelBooking(BuildContext context) {
    if (!_canCancelBooking) {
      Fluttertoast.showToast(
        msg: "Không thể hủy đặt sân khi còn dưới 30 phút so với giờ bắt đầu",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    String cancellationReason = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Xác nhận hủy đặt sân'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Bạn có chắc muốn hủy đặt sân này?'),
              Text(
                'Thời gian còn lại: ${_getRemainingTime()}',
                style: TextStyle(
                  color: _canCancelBooking ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Lý do hủy (tùy chọn)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  cancellationReason = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Không',
                style: TextStyle(color: Colors.blueGrey, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                try {
                  final bookingController = BookingController();
                  final success = await bookingController.cancelBooking(
                    bookingId: bookingId,
                    reason: cancellationReason,
                  );

                  if (success) {
                    Fluttertoast.showToast(
                      msg: "Đã hủy đặt sân thành công",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                    );
                    onCancel();
                  }
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: "Lỗi khi hủy đặt sân: ${e.toString()}",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                }
              },
              child: const Text(
                'Hủy đặt',
                style: TextStyle(color: Colors.red, fontSize: 17),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRemainingTime() {
    final now = DateTime.now();
    final difference = checkInTime.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày ${difference.inHours.remainder(24)} giờ';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ ${difference.inMinutes.remainder(60)} phút';
    } else {
      return '${difference.inMinutes} phút';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bookingStatus != 'confirmed' && bookingStatus != 'pending') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (!_canCancelBooking)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange[800], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Chỉ có thể hủy khi còn trên 30 phút so với giờ bắt đầu',
                      style: TextStyle(color: Colors.orange[800], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _canCancelBooking ? Colors.red : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: _canCancelBooking
                  ? () => _handleCancelBooking(context)
                  : null,
              child: Text(
                'Hủy đặt sân',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
