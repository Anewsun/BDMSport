import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String? id;
  final String courtId;
  final String userId;
  final String title;
  final String comment;
  final int rating;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userName;
  final String? userAvatar;
  final bool? isOwner;

  Review({
    this.id,
    required this.courtId,
    required this.userId,
    required this.title,
    required this.comment,
    required this.rating,
    required this.isAnonymous,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userAvatar,
    this.isOwner,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
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

    return Review(
      id: doc.id,
      courtId: data['courtId'] ?? '',
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      comment: data['comment'] ?? '',
      rating: data['rating'] ?? 0,
      isAnonymous: data['isAnonymous'] ?? false,
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap({bool isOwner = false}) {
    return {
      'id': id,
      'courtId': courtId,
      'userId': userId,
      'title': title,
      'comment': comment,
      'rating': rating,
      'isAnonymous': isAnonymous,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'date': '${createdAt.day}/${createdAt.month}/${createdAt.year}',
      'name': isAnonymous ? 'Ẩn danh' : (userName ?? 'Khách'),
      'userImage': isAnonymous
          ? 'assets/images/anonymous.png'
          : (userAvatar ?? 'assets/images/default-avatar.jpg'),
      'isOwner': isOwner,
      'images': [],
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'courtId': courtId,
      'userId': userId,
      'title': title,
      'comment': comment,
      'rating': rating,
      'isAnonymous': isAnonymous,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Review copyWith({
    String? id,
    String? courtId,
    String? userId,
    String? title,
    String? comment,
    int? rating,
    bool? isAnonymous,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? userAvatar,
    bool? isOwner,
  }) {
    return Review(
      id: id ?? this.id,
      courtId: courtId ?? this.courtId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      rating: rating ?? this.rating,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      isOwner: isOwner ?? this.isOwner,
    );
  }
}
