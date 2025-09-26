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
        return null;
      }

      final docRef = await _firestore
          .collection(collectionName)
          .add(booking.toMap());

      print('✅ Đã tạo booking thành công với ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Lỗi khi tạo booking: $e');
      return null;
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

  Future<bool> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      final updateData = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (status == 'completed') {
        updateData['completedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore
          .collection(collectionName)
          .doc(bookingId)
          .update(updateData);

      print('✅ Đã cập nhật trạng thái booking $bookingId thành: $status');
      return true;
    } catch (e) {
      print('❌ Lỗi khi cập nhật trạng thái booking: $e');
      return false;
    }
  }

  Future<bool> updatePaymentStatus({
    required String bookingId,
    required String paymentStatus,
  }) async {
    try {
      await _firestore.collection(collectionName).doc(bookingId).update({
        'paymentStatus': paymentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print(
        '✅ Đã cập nhật trạng thái thanh toán booking $bookingId thành: $paymentStatus',
      );
      return true;
    } catch (e) {
      print('❌ Lỗi khi cập nhật trạng thái thanh toán: $e');
      return false;
    }
  }

  Future<bool> updateBooking({
    required String bookingId,
    required Booking booking,
  }) async {
    try {
      if (!_validateBooking(booking)) {
        return false;
      }

      await _firestore
          .collection(collectionName)
          .doc(bookingId)
          .update(booking.toMap());

      print('✅ Đã cập nhật booking thành công: $bookingId');
      return true;
    } catch (e) {
      print('❌ Lỗi khi cập nhật booking: $e');
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
