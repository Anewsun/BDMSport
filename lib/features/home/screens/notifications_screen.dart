import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/controllers/notification_controller.dart';
import '../../../core/widgets/custom_header.dart';
import '../widgets/mark_all_as_read_button.dart';
import '../widgets/notification_item.dart';

final currentUserIdProvider = StreamProvider<String?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges.map((user) => user?.uid);
});

final notificationsStreamProvider = StreamProvider.autoDispose
    .family<List<NotificationModel>, String>((ref, userId) {
      final notificationController = ref.watch(notificationControllerProvider);
      return notificationController.getUserNotifications(userId);
    });

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Theo dõi changes của userId
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupUserListener();
    });
  }

  void _setupUserListener() {
    final currentUserIdAsync = ref.read(currentUserIdProvider);

    currentUserIdAsync.when(
      data: (userId) {
        if (userId != null) {
          _loadNotifications(userId);
        } else {
          setState(() {
            _loading = false;
            _error = 'Vui lòng đăng nhập để xem thông báo';
          });
        }
      },
      loading: () {
        setState(() {
          _loading = true;
          _error = null;
        });
      },
      error: (error, stackTrace) {
        setState(() {
          _loading = false;
          _error = 'Lỗi khi tải thông báo: $error';
        });
      },
    );
  }

  void _loadNotifications(String userId) {
    setState(() {
      _loading = true;
      _error = null;
    });

    // Stream sẽ tự động được quản lý bởi Provider
    setState(() {
      _loading = false;
    });
  }

  Future<void> _markAsRead(String id) async {
    if (!mounted) return;

    try {
      final notificationController = ref.read(notificationControllerProvider);
      await notificationController.markAsRead(id);
      _showToast('Đã đánh dấu là đã đọc');
    } catch (e) {
      _showToast('Lỗi khi đánh dấu đã đọc: $e', isError: true);
    }
  }

  Future<void> _markAllAsRead(String userId) async {
    if (!mounted) return;

    try {
      final notificationController = ref.read(notificationControllerProvider);
      await notificationController.markAllAsRead(userId);
      _showToast('Đã đánh dấu tất cả là đã đọc');
    } catch (e) {
      _showToast('Lỗi khi đánh dấu tất cả đã đọc: $e', isError: true);
    }
  }

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserIdAsync = ref.watch(currentUserIdProvider);
    final userId = currentUserIdAsync.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: 'Thông báo',
              showBackIcon: true,
              onBackPress: () => Navigator.pop(context),
              rightComponent: userId != null
                  ? MarkAllAsReadButton(onPressed: () => _markAllAsRead(userId))
                  : const SizedBox(width: 20),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => _setupUserListener(),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    )
                  : userId == null
                  ? const Center(
                      child: Text(
                        'Vui lòng đăng nhập để xem thông báo',
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    )
                  : _buildNotificationsList(userId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(String userId) {
    final notificationsAsync = ref.watch(notificationsStreamProvider(userId));

    return notificationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Lỗi: $error',
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () =>
                  ref.invalidate(notificationsStreamProvider(userId)),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
      data: (notifications) {
        if (notifications.isEmpty) {
          return const Center(
            child: Text(
              'Chưa có thông báo nào đến bạn',
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(notificationsStreamProvider(userId));
          },
          child: ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return NotificationItem(
                notification: notification,
                onPressed: _markAsRead,
              );
            },
          ),
        );
      },
    );
  }
}
