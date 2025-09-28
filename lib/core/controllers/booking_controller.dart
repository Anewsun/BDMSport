import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'bookings';

  Stream<List<Booking>> getBookingsByUser(String userId) {
    return _firestore
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<Booking>> getBookingsByUserAndStatus(
    String userId,
    String status,
  ) {
    return _firestore
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList(),
        );
  }

  Future<Booking?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore
          .collection(collectionName)
          .doc(bookingId)
          .get();

      if (doc.exists) {
        return Booking.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy booking: $e');
      return null;
    }
  }

  Future<String?> createBooking(Booking booking) async {
    try {
      if (!_validateBooking(booking)) {
        throw Exception('Thông tin booking không hợp lệ');
      }

      final isAvailable = await checkAreaAvailability(
        areaId: booking.areaId,
        checkIn: booking.checkIn,
        checkOut: booking.checkOut,
      );

      if (!isAvailable) {
        throw Exception('Khu vực đã được đặt trong khoảng thời gian này');
      }

      final bookingRef = _firestore.collection(collectionName).doc();
      await bookingRef.set(booking.toMap());
      await _firestore.collection('areas').doc(booking.areaId).update({
        'status': 'booked',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Đã tạo booking thành công với ID: ${bookingRef.id}');
      return bookingRef.id;
    } catch (e) {
      print('❌ Lỗi khi tạo booking: $e');
      rethrow;
    }
  }

  Future<void> applyVoucherToBooking({
    required String voucherId,
    required String userId,
    required String bookingId,
  }) async {
    try {
      final voucherRef = _firestore.collection('vouchers').doc(voucherId);
      final voucherDoc = await voucherRef.get();

      if (voucherDoc.exists) {
        final voucherData = voucherDoc.data() as Map<String, dynamic>;
        final currentUsageCount = voucherData['usageCount'] ?? 0;
        List<String> usedBy = List<String>.from(voucherData['usedBy'] ?? []);

        if (!usedBy.contains(userId)) {
          usedBy.add(userId);
        }

        final batch = _firestore.batch();
        batch.update(voucherRef, {
          'usageCount': currentUsageCount + 1,
          'usedBy': usedBy,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (voucherData['usageLimit'] != null &&
            (currentUsageCount + 1) >= voucherData['usageLimit']) {
          batch.update(voucherRef, {'status': 'inactive'});
        }

        await batch.commit();
      }
    } catch (e) {
      print('❌ Lỗi khi áp dụng voucher: $e');
      rethrow;
    }
  }

  Future<bool> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    try {
      final updateData = {
        'status': 'cancelled',
        'cancellationReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(collectionName)
          .doc(bookingId)
          .update(updateData);

      print('✅ Đã hủy booking thành công: $bookingId');
      return true;
    } catch (e) {
      print('❌ Lỗi khi hủy booking: $e');
      return false;
    }
  }

  Future<bool> confirmBooking(String bookingId) async {
    try {
      await _firestore.collection(collectionName).doc(bookingId).update({
        'status': 'confirmed',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('❌ Lỗi khi xác nhận booking: $e');
      return false;
    }
  }

  Future<bool> processPayment({
    required String bookingId,
    required String userId,
    required double amount,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final currentBalance = (userDoc.data()?['balance'] ?? 0).toDouble();
      if (currentBalance < amount) {
        throw Exception('Số dư không đủ');
      }

      final batch = _firestore.batch();

      batch.update(userRef, {
        'balance': currentBalance - amount,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.update(_firestore.collection(collectionName).doc(bookingId), {
        'status': 'completed',
        'paymentStatus': 'paid',
        'updatedAt': FieldValue.serverTimestamp(),
        'completedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return true;
    } catch (e) {
      print('❌ Lỗi khi xử lý thanh toán: $e');
      return false;
    }
  }

  Future<bool> checkAreaAvailability({
    required String areaId,
    required DateTime checkIn,
    required DateTime checkOut,
    String? excludeBookingId, // Loại trừ booking hiện tại khi cập nhật
  }) async {
    try {
      final query = _firestore
          .collection(collectionName)
          .where('areaId', isEqualTo: areaId)
          .where('status', whereIn: ['pending', 'confirmed']);

      final snapshot = await query.get();

      for (final doc in snapshot.docs) {
        final booking = Booking.fromFirestore(doc);

        if (excludeBookingId != null && booking.id == excludeBookingId) {
          continue;
        }

        if (_isDateRangeOverlap(
          checkIn,
          checkOut,
          booking.checkIn,
          booking.checkOut,
        )) {
          return false; // Có trùng lịch
        }
      }

      return true; // Không trùng lịch
    } catch (e) {
      print('❌ Lỗi khi kiểm tra availability: $e');
      return false;
    }
  }

  bool _isDateRangeOverlap(
    DateTime start1,
    DateTime end1,
    DateTime start2,
    DateTime end2,
  ) {
    return start1.isBefore(end2) && end1.isAfter(start2);
  }

  bool _validateBooking(Booking booking) {
    if (booking.checkIn.isAfter(booking.checkOut)) {
      print('❌ Lỗi: Thời gian check-in phải trước check-out');
      return false;
    }

    if (booking.finalPrice < 0) {
      print('❌ Lỗi: Giá cuối cùng không thể âm');
      return false;
    }

    if (booking.discountAmount < 0) {
      print('❌ Lỗi: Số tiền giảm giá không thể âm');
      return false;
    }

    if (booking.originalPrice < booking.discountAmount) {
      print('❌ Lỗi: Giá gốc không thể nhỏ hơn số tiền giảm giá');
      return false;
    }

    if (booking.contactInfo['name']?.isEmpty ?? true) {
      print('❌ Lỗi: Tên liên hệ không được để trống');
      return false;
    }

    if (booking.contactInfo['email']?.isEmpty ?? true) {
      print('❌ Lỗi: Email không được để trống');
      return false;
    }

    if (booking.contactInfo['phone']?.isEmpty ?? true) {
      print('❌ Lỗi: Số điện thoại không được để trống');
      return false;
    }

    return true;
  }
}
