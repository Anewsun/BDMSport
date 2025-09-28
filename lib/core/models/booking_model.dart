import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String? id;
  final String userId;
  final String areaId;
  final Map<String, String> contactInfo;
  final DateTime checkIn;
  final DateTime checkOut;
  final String? voucherId;
  final double originalPrice;
  final double discountAmount;
  final double finalPrice;
  final String status;
  final String paymentStatus;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    this.id,
    required this.userId,
    required this.areaId,
    required this.contactInfo,
    required this.checkIn,
    required this.checkOut,
    this.voucherId,
    required this.originalPrice,
    required this.discountAmount,
    required this.finalPrice,
    this.status = 'pending',
    this.paymentStatus = 'pending',
    this.cancelledAt,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    } else {
      throw Exception("Invalid date format: $value");
    }
  }

  factory Booking.fromMap(Map<String, dynamic> map, String id) {
    return Booking(
      id: id,
      userId: map['userId'] as String,
      areaId: map['areaId'] as String,
      contactInfo: Map<String, String>.from(map['contactInfo'] ?? {}),
      checkIn: _parseDate(map['checkIn']),
      checkOut: _parseDate(map['checkOut']),
      voucherId: map['voucherId'],
      originalPrice: (map['originalPrice'] ?? 0).toDouble(),
      discountAmount: (map['discountAmount'] ?? 0).toDouble(),
      finalPrice: (map['finalPrice'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      paymentStatus: map['paymentStatus'] ?? 'pending',
      cancelledAt: map['cancelledAt'] != null
          ? _parseDate(map['cancelledAt'])
          : null,
      cancellationReason: map['cancellationReason'],
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    return Booking.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'areaId': areaId,
      'contactInfo': contactInfo,
      'checkIn': checkIn,
      'checkOut': checkOut,
      'voucherId': voucherId,
      'originalPrice': originalPrice,
      'discountAmount': discountAmount,
      'finalPrice': finalPrice,
      'status': status,
      'paymentStatus': paymentStatus,
      'cancelledAt': cancelledAt,
      'cancellationReason': cancellationReason,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Booking copyWith({
    String? userId,
    String? areaId,
    Map<String, String>? contactInfo,
    DateTime? checkIn,
    DateTime? checkOut,
    String? voucherId,
    double? originalPrice,
    double? discountAmount,
    double? finalPrice,
    String? status,
    String? paymentStatus,
    DateTime? cancelledAt,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id,
      userId: userId ?? this.userId,
      areaId: areaId ?? this.areaId,
      contactInfo: contactInfo ?? this.contactInfo,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      voucherId: voucherId ?? this.voucherId,
      originalPrice: originalPrice ?? this.originalPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      finalPrice: finalPrice ?? this.finalPrice,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isPaymentPending => paymentStatus == 'pending';
  bool get isPaymentPaid => paymentStatus == 'paid';

  @override
  String toString() {
    return 'Booking(id: $id, userId: $userId, areaId: $areaId, status: $status, paymentStatus: $paymentStatus, finalPrice: $finalPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Booking && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum BookingStatus {
  pending('pending'),
  confirmed('confirmed'),
  completed('completed'),
  cancelled('cancelled');

  final String value;
  const BookingStatus(this.value);
}

enum PaymentStatus {
  pending('pending'),
  paid('paid');

  final String value;
  const PaymentStatus(this.value);
}
