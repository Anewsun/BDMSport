import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? provider;
  final bool isEmailVerified;
  final String? address;
  final String role;
  final String? avatar;
  final String status;
  final String tier;
  final double balance;
  final List<String> favoriteCourts;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.provider = 'local',
    this.isEmailVerified = false,
    this.address,
    this.role = 'customer',
    this.avatar,
    this.status = 'inactive',
    this.tier = 'Copper',
    this.balance = 0.0,
    this.favoriteCourts = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      provider: map['provider'] ?? 'local',
      isEmailVerified: map['isEmailVerified'] ?? false,
      address: map['address'],
      role: map['role'] ?? 'customer',
      avatar: map['avatar'],
      status: map['status'] ?? 'inactive',
      tier: map['tier'] ?? 'Copper',
      balance: (map['balance'] ?? 0).toDouble(),
      favoriteCourts: List<String>.from(map['favoriteCourts'] ?? []),
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: _parseTimestamp(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'provider': provider,
      'isEmailVerified': isEmailVerified,
      'address': address,
      'role': role,
      'avatar': avatar,
      'status': status,
      'tier': tier,
      'balance': balance,
      'favoriteCourts': favoriteCourts,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserModel activateAccount() {
    return UserModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      provider: provider,
      isEmailVerified: true,
      address: address,
      role: role,
      avatar: avatar,
      status: 'active',
      tier: tier,
      balance: balance,
      favoriteCourts: favoriteCourts,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? provider,
    bool? isEmailVerified,
    String? address,
    String? role,
    String? avatar,
    String? status,
    String? tier,
    double? balance,
    List<String>? favoriteCourts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      provider: provider ?? this.provider,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      address: address ?? this.address,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      tier: tier ?? this.tier,
      balance: balance ?? this.balance,
      favoriteCourts: favoriteCourts ?? this.favoriteCourts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
