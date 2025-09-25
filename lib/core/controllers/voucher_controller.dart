import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/voucher_model.dart';

class VoucherController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Voucher>> getAvailableVouchers({
    required String userId,
    required String userTier,
    required double orderValue,
    DateTime? currentDate,
  }) async {
    try {
      final now = currentDate ?? DateTime.now();

      final QuerySnapshot querySnapshot = await _firestore
          .collection(VoucherConstants.collectionName)
          .where('status', isEqualTo: 'active')
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .where('expiryDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .get();

      final List<Voucher> allVouchers = querySnapshot.docs
          .map((doc) => Voucher.fromFirestore(doc))
          .toList();

      final List<Voucher> availableVouchers = allVouchers.where((voucher) {
        return _isVoucherAvailableForUser(
          voucher,
          userId,
          userTier,
          orderValue,
          now,
        );
      }).toList();

      availableVouchers.sort((a, b) {
        final double discountA = a.calculateDiscount(orderValue);
        final double discountB = b.calculateDiscount(orderValue);
        return discountB.compareTo(discountA);
      });

      return availableVouchers;
    } catch (e) {
      print('❌ Lỗi khi lấy voucher: $e');
      return [];
    }
  }

  bool _isVoucherAvailableForUser(
    Voucher voucher,
    String userId,
    String userTier,
    double orderValue,
    DateTime currentDate,
  ) {
    if (voucher.usageCount >= voucher.usageLimit) {
      return false;
    }

    if (currentDate.isBefore(voucher.startDate) ||
        currentDate.isAfter(voucher.expiryDate)) {
      return false;
    }

    if (orderValue < voucher.minOrderValue) {
      return false;
    }

    if (!voucher.applicableTiers.contains(userTier)) {
      return false;
    }

    if (voucher.usedBy.contains(userId)) {
      return false;
    }

    return true;
  }

  Future<Voucher?> getVoucherByCode(String code) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(VoucherConstants.collectionName)
          .where('code', isEqualTo: code.toUpperCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return Voucher.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      print('❌ Lỗi khi lấy voucher bằng code: $e');
      return null;
    }
  }

  Future<bool> useVoucher({
    required String voucherId,
    required String userId,
    required String voucherCode,
  }) async {
    try {
      await _firestore
          .collection(VoucherConstants.collectionName)
          .doc(voucherId)
          .update({
            'usageCount': FieldValue.increment(1),
            'usedBy': FieldValue.arrayUnion([userId]),
            'updatedAt': Timestamp.now(),
          });

      print('✅ Đã sử dụng voucher: $voucherCode');
      return true;
    } catch (e) {
      print('❌ Lỗi khi sử dụng voucher: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> validateVoucher({
    required String voucherCode,
    required String userId,
    required String userTier,
    required double orderValue,
  }) async {
    try {
      final voucher = await getVoucherByCode(voucherCode);

      if (voucher == null) {
        return {
          'isValid': false,
          'message': 'Voucher không tồn tại',
          'voucher': null,
        };
      }

      final now = DateTime.now();

      if (!_isVoucherAvailableForUser(
        voucher,
        userId,
        userTier,
        orderValue,
        now,
      )) {
        return {
          'isValid': false,
          'message': 'Voucher không khả dụng',
          'voucher': voucher,
        };
      }

      final double discountAmount = voucher.calculateDiscount(orderValue);

      return {
        'isValid': true,
        'message': 'Áp dụng voucher thành công',
        'voucher': voucher,
        'discountAmount': discountAmount,
      };
    } catch (e) {
      return {
        'isValid': false,
        'message': 'Lỗi khi kiểm tra voucher: $e',
        'voucher': null,
      };
    }
  }

  Future<List<Voucher>> getAllVouchers() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(VoucherConstants.collectionName)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Voucher.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Lỗi khi lấy tất cả voucher: $e');
      return [];
    }
  }

  Future<Voucher?> getVoucherById(String voucherId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(VoucherConstants.collectionName)
          .doc(voucherId)
          .get();

      if (!doc.exists) return null;

      return Voucher.fromFirestore(doc);
    } catch (e) {
      print('❌ Lỗi khi lấy voucher bằng ID: $e');
      return null;
    }
  }
}
