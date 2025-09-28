import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/controllers/booking_controller.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/utils/booking_status_utils.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../navigation/bottom_nav_bar.dart';
import '../widgets/booking_card.dart';
import '../../auth/controllers/sign_in_controller.dart';

class BookingListScreen extends ConsumerStatefulWidget {
  const BookingListScreen({super.key});

  @override
  ConsumerState<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends ConsumerState<BookingListScreen> {
  String? _filterStatus;
  bool isLoading = false;
  bool _initialLoading = true;
  String? _error;
  Stream<List<Booking>>? _bookingsStream;

  final BookingController _bookingController = BookingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  String? get _userId {
    final authState = ref.read(signInControllerProvider);
    return authState.user?.id;
  }

  void _loadBookings() {
    final userId = _userId;

    if (userId == null) {
      setState(() {
        _initialLoading = false;
        _error = 'Vui lòng đăng nhập để xem lịch sử đặt sân';
      });
      return;
    }

    setState(() {
      isLoading = true;
      _error = null;
    });

    try {
      if (_filterStatus != null && _filterStatus!.isNotEmpty) {
        _bookingsStream = _bookingController.getBookingsByUserAndStatus(
          userId,
          _filterStatus!,
        );
      } else {
        _bookingsStream = _bookingController.getBookingsByUser(userId);
      }

      setState(() {
        _initialLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Lỗi khi tải dữ liệu: ${e.toString()}';
        _initialLoading = false;
        isLoading = false;
      });
    }
  }

  void _handleFilter(String? status) {
    setState(() {
      _filterStatus = status == _filterStatus ? null : status;
    });
    _loadBookings();
  }

  Future<Map<String, dynamic>> _bookingToMap(Booking booking) async {
    String areaName = 'Khu vực không xác định';

    try {
      final areaDoc = await FirebaseFirestore.instance
          .collection('areas')
          .doc(booking.areaId)
          .get();
      if (areaDoc.exists) {
        areaName = areaDoc.data()?['nameArea'] ?? areaName;
      }
    } catch (_) {}

    String checkInStr;
    String checkOutStr;

    try {
      checkInStr = booking.checkIn.toIso8601String();
    } catch (_) {
      checkInStr = booking.checkIn.toString();
    }

    try {
      checkOutStr = booking.checkOut.toIso8601String();
    } catch (_) {
      checkOutStr = booking.checkOut.toString();
    }

    return {
      'id': booking.id,
      'areaId': booking.areaId,
      'area': {'name': areaName},
      'checkIn': checkInStr,
      'checkOut': checkOutStr,
      'status': booking.status,
      'finalPrice': booking.finalPrice,
      'originalPrice': booking.originalPrice,
      'discountAmount': booking.discountAmount,
      'contactInfo': booking.contactInfo,
    };
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(signInControllerProvider);

    if (authState.isLoading && _initialLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF003366)),
        ),
      );
    }

    return BottomNavBar(
      child: Scaffold(
        backgroundColor: const Color(0xFFf0f4ff),
        body: SafeArea(
          child: Column(
            children: [
              CustomHeader(
                title: 'Lịch sử đặt sân',
                showBackIcon: false,
                rightComponent: PopupMenuButton<String?>(
                  icon: Icon(
                    Icons.filter_list,
                    color: _filterStatus != null
                        ? BookingStatusUtils.getStatusColor(_filterStatus!)
                        : null,
                  ),
                  onSelected: _handleFilter,
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: null, child: Text('Tất cả')),
                    const PopupMenuDivider(),
                    ...['pending', 'confirmed', 'cancelled', 'completed'].map((
                      status,
                    ) {
                      return PopupMenuItem(
                        value: status,
                        child: Text(
                          BookingStatusUtils.getStatusText(status),
                          style: TextStyle(
                            fontWeight: _filterStatus == status
                                ? FontWeight.bold
                                : null,
                            color: _filterStatus == status
                                ? const Color(0xFF003366)
                                : null,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Expanded(child: _buildContent(authState)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AuthState authState) {
    if (_initialLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF003366)),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBookings,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_bookingsStream == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF003366)),
            const SizedBox(height: 16),
            const Text('Đang kết nối...'),
          ],
        ),
      );
    }

    return StreamBuilder<List<Booking>>(
      stream: _bookingsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Lỗi: ${snapshot.error}',
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadBookings,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF003366)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📭', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 16),
                Text(
                  _filterStatus != null
                      ? 'Không có booking ${BookingStatusUtils.getStatusText(_filterStatus!)}'
                      : 'Chưa có sân nào được đặt',
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
                const SizedBox(height: 8),
                Text(
                  _filterStatus != null
                      ? 'Thử lọc trạng thái khác'
                      : 'Hãy đặt sân đầu tiên của bạn!',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final bookings = snapshot.data!;

        return RefreshIndicator(
          onRefresh: () async {
            _loadBookings();
            await Future.delayed(const Duration(seconds: 1));
          },
          color: const Color(0xFF003366),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return FutureBuilder<Map<String, dynamic>>(
                future: _bookingToMap(booking),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: LinearProgressIndicator(),
                    );
                  }
                  return BookingCard(
                    booking: snapshot.data!,
                    onPress: () {
                      final bookingId = booking.id;
                      if (bookingId == null || bookingId.isEmpty) {
                        return;
                      }

                      context.push('/booking-detail/$bookingId');
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
