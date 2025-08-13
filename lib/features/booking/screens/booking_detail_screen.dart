import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/review_form_modal.dart';
import '../widgets/cancel_button_widget.dart';
import '../widgets/info_cards.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  Map<String, dynamic>? _booking;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
  }

  Future<void> _loadBookingDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      final mockBooking = {
        'id': widget.bookingId,
        'area': {
          'name': 'Sân cầu lông số 1',
          'images': ['assets/images/court4.jpg'],
        },
        'checkIn': DateTime.now().add(const Duration(days: 1)),
        'checkOut': DateTime.now().add(const Duration(days: 1, hours: 2)),
        'status': 'completed',
        'finalPrice': 200000,
        'contactInfo': {'name': 'Nguyễn Văn An', 'phone': '0987654321'},
        'bookingFor': 'self',
        'paymentMethod': 'cash',
        'paymentStatus': 'paid',
        'specialRequests': {'additionalRequests': 'Cần 2 chai nước miễn phí'},
      };

      setState(() {
        _booking = mockBooking;
      });
    } catch (e) {
      setState(() {
        _error = 'Lỗi khi tải dữ liệu: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (_booking == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy thông tin đặt sân')),
      );
    }

    final booking = _booking!;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: 'Chi tiết đặt sân',
              showBackIcon: true,
              onBackPress: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        booking['area']['images'][0],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    BookingInfoCard(booking: booking),
                    const SizedBox(height: 16),
                    CustomerInfoCard(booking: booking),
                    const SizedBox(height: 16),
                    PaymentInfoCard(booking: booking),
                    const SizedBox(height: 16),
                    SpecialRequestsCard(booking: booking),
                    const SizedBox(height: 16),

                    if (booking['status'] == 'confirmed' ||
                        booking['status'] == 'pending')
                      CancelButtonWidget(
                        onCancel: () => Navigator.pop(context),
                        bookingStatus: booking['status'],
                      )
                    else if (booking['status'] == 'completed')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => ReviewFormModal(
                                  visible: true,
                                  onClose: () => Navigator.pop(context),
                                  onSubmit: () {
                                    Navigator.pop(context);
                                    Fluttertoast.showToast(
                                      msg: "Cảm ơn bạn đã đánh giá!",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white
                                    );
                                  },
                                ),
                              );
                            },
                            child: const Text(
                              'Để lại đánh giá',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
