import 'package:cloud_firestore/cloud_firestore.dart';

enum AreaStatus { available, booked }

class Area {
  final String? id;
  final List<String> amenities;
  final String courtId;
  final String courtType;
  final DateTime createdAt;
  final String description;
  final double discountPercent;
  final String image;
  final String nameArea;
  final double price;
  final AreaStatus status;

  Area({
    this.id,
    required this.amenities,
    required this.courtId,
    required this.courtType,
    required this.createdAt,
    required this.description,
    required this.discountPercent,
    required this.image,
    required this.nameArea,
    required this.price,
    required this.status,
  });

  factory Area.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    DateTime parseTimestamp(dynamic timestamp) {
    if (timestamp == null) {
      return DateTime.now();
    }
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    return DateTime.now();
  }

    return Area(
      id: doc.id,
      amenities: List<String>.from(data['amenities'] ?? []),
      courtId: data['courtId'] ?? '',
      courtType: data['courtType'] ?? '',
      createdAt: parseTimestamp(data['createdAt']),
      description: data['description'] ?? '',
      discountPercent: (data['discountPercent'] ?? 0).toDouble(),
      image: data['image'] ?? '',
      nameArea: data['nameArea'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      status: _parseStatus(data['status']),
    );
  }

  static AreaStatus _parseStatus(String status) {
    switch (status) {
      case 'available':
        return AreaStatus.available;
      case 'booked':
        return AreaStatus.booked;
      default:
        return AreaStatus.available;
    }
  }

  static String _statusToString(AreaStatus status) {
    switch (status) {
      case AreaStatus.available:
        return 'available';
      case AreaStatus.booked:
        return 'booked';
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'amenities': amenities,
      'courtId': courtId,
      'courtType': courtType,
      'createdAt': Timestamp.fromDate(createdAt),
      'description': description,
      'discountPercent': discountPercent,
      'image': image,
      'nameArea': nameArea,
      'price': price,
      'status': _statusToString(status),
    };
  }

  Map<String, dynamic> toMap() {
  return {
    'id': id,
    'nameArea': nameArea,
    'image': image,
    'price': price,
    'discountPercent': discountPercent,
    'description': description,
    'courtType': courtType,
    'amenities': amenities,
    'status': _statusToString(status),
  };
}

  Area copyWith({
    String? id,
    List<String>? amenities,
    String? courtId,
    String? courtType,
    DateTime? createdAt,
    String? description,
    double? discountPercent,
    String? image,
    String? nameArea,
    double? price,
    AreaStatus? status,
  }) {
    return Area(
      id: id ?? this.id,
      amenities: amenities ?? this.amenities,
      courtId: courtId ?? this.courtId,
      courtType: courtType ?? this.courtType,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      discountPercent: discountPercent ?? this.discountPercent,
      image: image ?? this.image,
      nameArea: nameArea ?? this.nameArea,
      price: price ?? this.price,
      status: status ?? this.status,
    );
  }

  // Tính giá sau khi giảm
  double get discountedPrice {
    return price * (1 - discountPercent / 100);
  }

  @override
  String toString() {
    return 'Area(id: $id, nameArea: $nameArea, status: ${_statusToString(status)}, price: $price, discountedPrice: $discountedPrice)';
  }
}
