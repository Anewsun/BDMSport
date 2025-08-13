import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/booking_status_utils.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../navigation/bottom_nav_bar.dart';
import '../widgets/booking_card.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  String? _filterStatus;
  bool _isLoading = false;
  bool _initialLoading = true;
  String? _error;
  final List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      final mockBookings = [
        {
          'id': '1',
          'area': {
            'name': 'Sân cầu lông số 1',
            'images': ['assets/images/court1.jpg'],
          },
          'checkIn': DateTime.now()
              .add(const Duration(days: 1))
              .toIso8601String(),
          'checkOut': DateTime.now()
              .add(const Duration(days: 1, hours: 2))
              .toIso8601String(),
          'status': 'confirmed',
          'finalPrice': 200000,
          'originalPrice': 220000,
          'discountAmount': 20000,
          'contactInfo': {'name': 'Nguyễn Văn An'},
        },
        {
          'id': '2',
          'area': {
            'name': 'Sân cầu lông số 2',
            'images': ['assets/images/court4.jpg'],
          },
          'checkIn': DateTime.now()
              .subtract(const Duration(days: 2))
              .toIso8601String(),
          'checkOut': DateTime.now()
              .subtract(const Duration(days: 2, hours: 1, minutes: 30))
              .toIso8601String(),
          'status': 'completed',
          'finalPrice': 150000,
          'originalPrice': 150000,
          'contactInfo': {'name': 'Trần Thị Bảy'},
        },
      ];

      setState(() {
        _bookings.clear();
        _bookings.addAll(mockBookings);
        _initialLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Lỗi khi tải dữ liệu: ${e.toString()}';
        _initialLoading = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleFilter(String? status) {
    setState(() {
      _filterStatus = status == _filterStatus ? null : status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredBookings = _filterStatus != null
        ? _bookings
              .where((booking) => booking['status'] == _filterStatus)
              .toList()
        : _bookings;

    if (_initialLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF003366)),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
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
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF003366),
                        ),
                      )
                    : filteredBookings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('📭', style: TextStyle(fontSize: 40)),
                            const SizedBox(height: 16),
                            Text(
                              _filterStatus != null
                                  ? 'Không có booking ${BookingStatusUtils.getStatusText(_filterStatus!)}'
                                  : 'Chưa có sân nào được đặt',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _filterStatus != null
                                  ? 'Thử lọc trạng thái khác'
                                  : 'Hãy đặt sân đầu tiên của bạn!',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadBookings,
                        color: const Color(0xFF003366),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredBookings.length,
                          itemBuilder: (context, index) {
                            final booking = filteredBookings[index];
                            return BookingCard(
                              booking: booking,
                              onPress: () {
                                context.push('/booking-detail');
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
