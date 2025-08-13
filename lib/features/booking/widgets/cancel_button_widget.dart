import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CancelButtonWidget extends StatelessWidget {
  final VoidCallback onCancel;
  final String bookingStatus;

  const CancelButtonWidget({
    super.key,
    required this.onCancel,
    required this.bookingStatus,
  });

  void _handleCancelBooking(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy đặt sân'),
        content: const Text('Bạn có chắc muốn hủy đặt sân này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Không',
              style: TextStyle(color: Colors.blueGrey, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: "Đã hủy đặt sân thành công",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              onCancel();
            },
            child: const Text(
              'Hủy đặt',
              style: TextStyle(color: Colors.red, fontSize: 17),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (bookingStatus != 'confirmed' && bookingStatus != 'pending') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onPressed: () => _handleCancelBooking(context),
          child: const Text(
            'Hủy đặt sân',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
