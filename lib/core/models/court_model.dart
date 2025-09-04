import 'package:cloud_firestore/cloud_firestore.dart';

class Court {
  final String id;
  final String name;
  final String address;
  final String locationId;
  final double rating;
  final String description;
  final String ownerId;
  final String? featuredImage;
  final List<String> images;
  final List<String> amenities;
  final Map<String, dynamic> policies;
  final double lowestPrice;
  final double lowestDiscountedPrice;
  final double highestDiscountPercent;
  final String status;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Court({
    required this.id,
    required this.name,
    required this.address,
    required this.locationId,
    required this.rating,
    required this.description,
    required this.ownerId,
    this.featuredImage,
    required this.images,
    required this.amenities,
    required this.policies,
    required this.lowestPrice,
    required this.lowestDiscountedPrice,
    required this.highestDiscountPercent,
    this.status = "active",
    required this.createdAt,
    required this.updatedAt,
  });

  factory Court.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;

    return Court(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      locationId: data['locationId'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      ownerId: data['ownerId'] ?? '',
      featuredImage: data['featuredImage'],
      images: List<String>.from(data['images'] ?? []),
      amenities: List<String>.from(data['amenities'] ?? []),
      policies: Map<String, dynamic>.from(data['policies'] ?? {}),
      lowestPrice: (data['lowestPrice'] ?? 0).toDouble(),
      lowestDiscountedPrice: (data['lowestDiscountedPrice'] ?? 0).toDouble(),
      highestDiscountPercent: (data['highestDiscountPercent'] ?? 0).toDouble(),
      status: data['status'] ?? 'active',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'locationId': locationId,
      'rating': rating,
      'description': description,
      'ownerId': ownerId,
      'featuredImage': featuredImage,
      'images': images,
      'amenities': amenities,
      'policies': policies,
      'lowestPrice': lowestPrice,
      'lowestDiscountedPrice': lowestDiscountedPrice,
      'highestDiscountPercent': highestDiscountPercent,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
