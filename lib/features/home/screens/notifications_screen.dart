import 'package:flutter/material.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/widgets/custom_header.dart';
import '../widgets/mark_all_as_read_button.dart';
import '../widgets/notification_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = false;
  String? _error;
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    setState(() {
      _loading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _notifications = [
          NotificationModel(
            id: '1',
            title: 'Đặt sân thành công',
            message: 'Bạn đã đặt sân cầu lông lúc 17:00 ngày 15/08/2025',
            type: 'booking',
            status: 'unread',
            createdAt: DateTime.now()
                .subtract(const Duration(minutes: 30))
                .toIso8601String(),
          ),
          NotificationModel(
            id: '2',
            title: 'Voucher mới',
            message: 'Bạn có voucher giảm 20% cho lần đặt sân tiếp theo',
            type: 'voucher',
            status: 'read',
            createdAt: DateTime.now()
                .subtract(const Duration(hours: 2))
                .toIso8601String(),
          ),
          NotificationModel(
            id: '3',
            title: 'Thông báo hệ thống',
            message: 'Hệ thống sẽ bảo trì từ 23:00 đến 02:00 ngày mai',
            type: 'admin',
            status: 'read',
            createdAt: DateTime.now()
                .subtract(const Duration(days: 1))
                .toIso8601String(),
          ),
        ];
        _loading = false;
      });
    });
  }

  void _markAsRead(String id) {
    setState(() {
      _notifications = _notifications.map((notification) {
        if (notification.id == id) {
          return notification.copyWith(status: 'read');
        }
        return notification;
      }).toList();
    });
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((notification) {
        return notification.copyWith(status: 'read');
      }).toList();
    });
  }

  void _refresh() {
    _loadMockData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: 'Thông báo',
              showBackIcon: true,
              onBackPress: () => Navigator.pop(context),
              rightComponent: MarkAllAsReadButton(onPressed: _markAllAsRead),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    )
                  : _notifications.isEmpty
                  ? const Center(
                      child: Text(
                        'Không có thông báo mới',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        _refresh();
                      },
                      child: ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return NotificationItem(
                            notification: notification,
                            onPressed: _markAsRead,
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
