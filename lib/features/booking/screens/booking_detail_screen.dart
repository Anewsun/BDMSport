import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/controllers/booking_controller.dart';
import '../../../core/controllers/review_controller.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/review_form_modal.dart';
import '../widgets/cancel_button_widget.dart';
import '../widgets/info_cards.dart';
import '../../auth/controllers/sign_in_controller.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  ConsumerState<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  Map<String, dynamic>? _booking;
  bool _isLoading = true;
  String? _error;
  bool _hasUserReviewed = false;
  double? _userBalance;

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
    _loadUserBalance();
  }

  String? get _userId {
    final authState = ref.read(signInControllerProvider);
    return authState.user?.id;
  }

  Future<void> _loadUserBalance() async {
    try {
      final userId = _userId;
      if (userId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userBalance = (userDoc.data()?['balance'] ?? 0).toDouble();
          });
        }
      }
    } catch (e) {
      print('Lỗi khi load số dư: $e');
    }
  }

  Future<void> _loadBookingDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bookingController = BookingController();
      final booking = await bookingController.getBookingById(widget.bookingId);

      if (booking != null) {
        final areaDoc = await FirebaseFirestore.instance
            .collection('areas')
            .doc(booking.areaId)
            .get();

        String areaName = 'Khu vực không xác định';
        List<String> areaImages = ['assets/images/court4.jpg'];

        if (areaDoc.exists) {
          final areaData = areaDoc.data()!;
          areaName = areaData['nameArea'] ?? areaName;
          if (areaData['image'] != null && areaData['image'] is List) {
            areaImages = List<String>.from(areaData['image']);
          }
        }

        if (booking.status == 'completed') {
          await _checkUserReview(booking.areaId);
        }

        setState(() {
          _booking = {
            'id': booking.id,
            'area': {
              'id': booking.areaId,
              'name': areaName,
              'image': areaImages,
            },
            'checkIn': booking.checkIn,
            'checkOut': booking.checkOut,
            'status': booking.status,
            'originalPrice': booking.originalPrice,
            'discountAmount': booking.discountAmount,
            'finalPrice': booking.finalPrice,
            'contactInfo': booking.contactInfo,
            'paymentStatus': booking.paymentStatus,
            'userId': booking.userId,
          };
        });
      } else {
        setState(() {
          _error = 'Không tìm thấy thông tin đặt sân';
        });
      }
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

  Future<void> _checkUserReview(String areaId) async {
    try {
      final reviewController = ReviewController();
      final userReview = await reviewController.getUserReviewForCourt(areaId);
      setState(() {
        _hasUserReviewed = userReview != null;
      });
    } catch (e) {
      print('Lỗi khi kiểm tra đánh giá: $e');
    }
  }

  void _showQRScanPopup() {
    final booking = _booking!;
    final amount = booking['finalPrice'];

    if (_userBalance == null || _userBalance! < amount) {
      _showInsufficientBalanceDialog();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quét mã QR'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/qr_code.png', height: 150, width: 150),
            const SizedBox(height: 16),
            const Text('Vui lòng quét mã QR để xác nhận thanh toán'),
            const SizedBox(height: 8),
            Text(
              'Số dư hiện tại: ${formatPrice(_userBalance!)}',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Số tiền cần thanh toán: ${formatPrice(amount)}',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: _confirmBooking,
            child: const Text('Xác nhận thanh toán'),
          ),
        ],
      ),
    );
  }

  void _showInsufficientBalanceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Số dư không đủ'),
        content: const Text(
          'Số dư của bạn không đủ để thực hiện đặt sân. Vui lòng nạp thêm tiền trong phần Hồ sơ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/profile');
            },
            child: const Text('Đến Hồ sơ'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmBooking() async {
    try {
      final bookingController = BookingController();
      final success = await bookingController.confirmBooking(widget.bookingId);

      if (success) {
        Navigator.pop(context);
        await _loadBookingDetails();
        Fluttertoast.showToast(
          msg: "Đã xác nhận bắt đầu chơi thành công!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Lỗi khi xác nhận: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _showPaymentPopup() {
    final booking = _booking!;
    final amount = booking['finalPrice'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thanh toán'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Số tiền cần thanh toán: ${formatPrice(amount)}'),
            const SizedBox(height: 8),
            Text(
              'Số dư hiện tại: ${formatPrice(_userBalance!)}',
              style: TextStyle(
                color: _userBalance! >= amount ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_userBalance! < amount)
              const Text(
                'Số dư không đủ! Vui lòng nạp thêm tiền.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: _userBalance! >= amount
                ? () => _processPayment(amount)
                : null,
            child: const Text('Thanh toán'),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment(double amount) async {
    try {
      final bookingController = BookingController();
      final userId = _userId;

      if (userId == null) {
        throw Exception('User không tồn tại');
      }

      final success = await bookingController.processPayment(
        bookingId: widget.bookingId,
        userId: userId,
        amount: amount,
      );

      if (success) {
        Navigator.pop(context);
        await _loadBookingDetails();
        await _loadUserBalance();

        Fluttertoast.showToast(
          msg: "Thanh toán thành công!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Lỗi thanh toán: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _showReviewForm() {
    showDialog(
      context: context,
      builder: (context) => ReviewFormModal(
        visible: true,
        onClose: () => Navigator.pop(context),
        onSubmit: (reviewData) async {
          try {
            final reviewController = ReviewController();
            final areaId = _booking!['area']['id'];

            await reviewController.createReview(
              areaId,
              reviewData['rating'],
              reviewData['title'],
              reviewData['comment'],
              reviewData['isAnonymous'] ?? false,
            );

            Navigator.pop(context);
            setState(() {
              _hasUserReviewed = true;
            });

            Fluttertoast.showToast(
              msg: "Cảm ơn bạn đã đánh giá!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
          } catch (e) {
            Fluttertoast.showToast(
              msg: "Lỗi khi gửi đánh giá: ${e.toString()}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
        },
      ),
    );
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
    final status = booking['status'];

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
                        booking['area']['image'].isNotEmpty
                            ? booking['area']['image'][0]
                            : 'assets/images/court4.jpg',
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

                    if (status == 'pending' || status == 'confirmed')
                      Column(
                        children: [
                          if (status == 'pending')
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onPressed: _showQRScanPopup,
                                  child: const Text(
                                    'Quét mã QR',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          if (status == 'confirmed')
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onPressed: _showPaymentPopup,
                                  child: const Text(
                                    'Thanh toán',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 8),
                          CancelButtonWidget(
                            onCancel: () async {
                              await _loadBookingDetails();
                            },
                            bookingStatus: status,
                            bookingId: widget.bookingId,
                            checkInTime: booking['checkIn'],
                          ),
                        ],
                      )
                    else if (status == 'completed' && !_hasUserReviewed)
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
                            onPressed: _showReviewForm,
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
