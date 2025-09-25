import 'package:cloud_firestore/cloud_firestore.dart';

class Voucher {
  final String id;
  final String code;
  final double discount;
  final DateTime startDate;
  final DateTime expiryDate;
  final String status;
  final int usageLimit;
  final int usageCount;
  final double minOrderValue;
  final bool discountType;
  final double maxDiscount;
  final List<String> applicableTiers;
  final List<String> usedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Voucher({
    required this.id,
    required this.code,
    required this.discount,
    required this.startDate,
    required this.expiryDate,
    required this.status,
    required this.usageLimit,
    required this.usageCount,
    required this.minOrderValue,
    required this.discountType,
    required this.maxDiscount,
    required this.applicableTiers,
    required this.usedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'discount': discount,
      'startDate': Timestamp.fromDate(startDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'status': status,
      'usageLimit': usageLimit,
      'usageCount': usageCount,
      'minOrderValue': minOrderValue,
      'discountType': discountType,
      'maxDiscount': maxDiscount,
      'applicableTiers': applicableTiers,
      'usedBy': usedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Voucher.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Voucher(
      id: doc.id,
      code: data['code'] ?? '',
      discount: (data['discount'] ?? 0).toDouble(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'inactive',
      usageLimit: (data['usageLimit'] ?? 0).toInt(),
      usageCount: (data['usageCount'] ?? 0).toInt(),
      minOrderValue: (data['minOrderValue'] ?? 0).toDouble(),
      discountType: data['discountType'] ?? false,
      maxDiscount: (data['maxDiscount'] ?? 0).toDouble(),
      applicableTiers: List<String>.from(data['applicableTiers'] ?? []),
      usedBy: List<String>.from(data['usedBy'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory Voucher.fromMap(Map<String, dynamic> data) {
    return Voucher(
      id: data['id'] ?? '',
      code: data['code'] ?? '',
      discount: (data['discount'] ?? 0).toDouble(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'inactive',
      usageLimit: (data['usageLimit'] ?? 0).toInt(),
      usageCount: (data['usageCount'] ?? 0).toInt(),
      minOrderValue: (data['minOrderValue'] ?? 0).toDouble(),
      discountType: data['discountType'] ?? false,
      maxDiscount: (data['maxDiscount'] ?? 0).toDouble(),
      applicableTiers: List<String>.from(data['applicableTiers'] ?? []),
      usedBy: List<String>.from(data['usedBy'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Voucher copyWith({
    String? id,
    String? code,
    double? discount,
    DateTime? startDate,
    DateTime? expiryDate,
    String? status,
    int? usageLimit,
    int? usageCount,
    double? minOrderValue,
    bool? discountType,
    double? maxDiscount,
    List<String>? applicableTiers,
    List<String>? usedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Voucher(
      id: id ?? this.id,
      code: code ?? this.code,
      discount: discount ?? this.discount,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
      minOrderValue: minOrderValue ?? this.minOrderValue,
      discountType: discountType ?? this.discountType,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      applicableTiers: applicableTiers ?? this.applicableTiers,
      usedBy: usedBy ?? this.usedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isValid {
    final now = DateTime.now();
    return status == 'active' &&
        now.isAfter(startDate) &&
        now.isBefore(expiryDate) &&
        usageCount < usageLimit;
  }

  double calculateDiscount(double orderValue) {
    if (orderValue < minOrderValue) return 0;

    double discountAmount = 0;

    if (discountType) {
      discountAmount = orderValue * discount / 100;
      if (maxDiscount > 0 && discountAmount > maxDiscount) {
        discountAmount = maxDiscount;
      }
    } else {
      discountAmount = discount;
    }

    return discountAmount;
  }

  @override
  String toString() {
    return 'Voucher(id: $id, code: $code, discount: $discount, status: $status, expiryDate: $expiryDate)';
  }
}

class VoucherConstants {
  static const String active = 'active';
  static const String inactive = 'inactive';

  static const bool fixedAmount = false;
  static const bool percentage = true;

  static const String collectionName = 'vouchers';
}
