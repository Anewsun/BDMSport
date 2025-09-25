import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../models/voucher_model.dart';
import '../utils/formatters.dart';

class NotificationController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'notifications';

  Stream<List<NotificationModel>> getUserNotifications(
    String userId, {
    bool sortByLatest = true,
  }) {
    try {
      Query query = _firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId);

      if (sortByLatest) {
        query = query.orderBy('createdAt', descending: true);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return NotificationModel.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();
      });
    } catch (e) {
      print('Error getting user notifications: $e');
      rethrow;
    }
  }

  Stream<List<NotificationModel>> getUnreadNotifications(String userId) {
    try {
      return _firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'unread')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return NotificationModel.fromJson(doc.data(), doc.id);
            }).toList();
          });
    } catch (e) {
      print('Error getting unread notifications: $e');
      rethrow;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection(collectionName).doc(notificationId).update({
        'status': 'read',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'unread')
          .get();

      final batch = _firestore.batch();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'status': 'read',
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  Future<NotificationModel> createBookingNotification({
    required String userId,
    required String bookingId,
    required DateTime checkIn,
    required DateTime checkOut,
    required String areaName,
  }) async {
    try {
      final notification = NotificationModel.create(
        userId: userId,
        title: 'Xác nhận đặt sân',
        message:
            'Đơn đặt sân #$bookingId từ ${formatDate(checkIn)} đến ${formatDate(checkOut)} đã được tạo thành công. Vui lòng thanh toán để xác nhận.',
        type: NotificationType.booking,
        relatedId: bookingId,
        refModel: RefModel.booking,
      );

      final docRef = await _firestore
          .collection(collectionName)
          .add(notification.toJson());

      return notification.copyWith(id: docRef.id);
    } catch (e) {
      print('Error creating booking notification: $e');
      rethrow;
    }
  }

  Future<List<NotificationModel>> createVoucherNotification({
    required Voucher voucher,
    required List<String> userIds,
  }) async {
    try {
      String discountInfo = voucher.discountType == VoucherConstants.percentage
          ? 'giảm ${voucher.discount}% (tối đa ${voucher.maxDiscount.toInt()}đ)'
          : 'giảm ${voucher.discount.toInt()}đ';

      final notifications = <NotificationModel>[];
      final batch = _firestore.batch();

      for (final userId in userIds) {
        final notification = NotificationModel.create(
          userId: userId,
          title: 'Ưu đãi mới dành cho bạn',
          message:
              'Mã giảm giá "${voucher.code}" vừa được cập nhật, $discountInfo cho đơn đặt sân. Đơn tối thiểu ${voucher.minOrderValue.toInt()}đ. Hạn sử dụng: ${formatDate(voucher.expiryDate)}.',
          type: NotificationType.voucher,
          relatedId: voucher.id,
          refModel: RefModel.voucher,
        );

        final docRef = _firestore.collection(collectionName).doc();
        batch.set(docRef, notification.toJson());
        notifications.add(notification.copyWith(id: docRef.id));
      }

      await batch.commit();
      return notifications;
    } catch (e) {
      print('Error creating voucher notification: $e');
      rethrow;
    }
  }

  Future<List<NotificationModel>> createAdminNotification({
    required List<String> userIds,
    String title = 'Thông báo từ hệ thống',
    required String message,
  }) async {
    try {
      final notifications = <NotificationModel>[];
      final batch = _firestore.batch();

      for (final userId in userIds) {
        final notification = NotificationModel.create(
          userId: userId,
          title: title,
          message: message,
          type: NotificationType.admin,
        );

        final docRef = _firestore.collection(collectionName).doc();
        batch.set(docRef, notification.toJson());
        notifications.add(notification.copyWith(id: docRef.id));
      }

      await batch.commit();
      return notifications;
    } catch (e) {
      print('Error creating admin notification: $e');
      rethrow;
    }
  }

  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'unread')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}

final notificationControllerProvider = Provider<NotificationController>((ref) {
  return NotificationController();
});
