import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String? id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  NotificationStatus status;
  final String? relatedId;
  final RefModel? refModel;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.status = NotificationStatus.unread,
    this.relatedId,
    this.refModel,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'relatedId': relatedId,
      'refModel': refModel?.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json, String id) {
    return NotificationModel(
      id: id,
      userId: json['userId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => NotificationType.admin,
      ),
      status: NotificationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => NotificationStatus.unread,
      ),
      relatedId: json['relatedId'] as String?,
      refModel: json['refModel'] != null
          ? RefModel.values.firstWhere(
              (e) => e.toString().split('.').last == json['refModel'],
              orElse: () => RefModel.booking,
            )
          : null,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory NotificationModel.create({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    String? relatedId,
    RefModel? refModel,
  }) {
    final now = DateTime.now();
    return NotificationModel(
      userId: userId,
      title: title,
      message: message,
      type: type,
      relatedId: relatedId,
      refModel: refModel,
      createdAt: now,
      updatedAt: now,
    );
  }

  void markAsRead() {
    status = NotificationStatus.read;
  }

  void markAsUnread() {
    status = NotificationStatus.unread;
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    NotificationStatus? status,
    String? relatedId,
    RefModel? refModel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      status: status ?? this.status,
      relatedId: relatedId ?? this.relatedId,
      refModel: refModel ?? this.refModel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum NotificationType { booking, voucher, admin, payment }

enum NotificationStatus { unread, read }

enum RefModel { booking, voucher }

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.booking:
        return 'Đặt sân';
      case NotificationType.voucher:
        return 'Voucher';
      case NotificationType.admin:
        return 'Quản trị';
      case NotificationType.payment:
        return 'Thanh toán';
    }
  }
}

extension NotificationStatusExtension on NotificationStatus {
  String get displayName {
    switch (this) {
      case NotificationStatus.unread:
        return 'Chưa đọc';
      case NotificationStatus.read:
        return 'Đã đọc';
    }
  }
}
