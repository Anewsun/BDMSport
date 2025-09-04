import 'package:cloud_firestore/cloud_firestore.dart';

class LocationModel {
  final String id;
  final String name;
  final String image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LocationModel({
    required this.id,
    required this.name,
    required this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory LocationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return LocationModel(
      id: doc.id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }
}
