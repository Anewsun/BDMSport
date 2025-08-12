import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool showDate;
  final Widget? richContent;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isSender,
    this.showDate = false,
    this.richContent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        if (showDate)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              formatDate(message.createdAt),
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ),
        const SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: isSender
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!isSender)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage(
                    'assets/images/default-avatar.jpg',
                  ),
                ),
              ),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isSender
                      ? const Radius.circular(12)
                      : const Radius.circular(2),
                  bottomRight: isSender
                      ? const Radius.circular(2)
                      : const Radius.circular(12),
                ),
                color: isSender ? const Color(0xFFDCF8C6) : Colors.grey[200],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.text != null && message.text!.isNotEmpty)
                    Text(
                      message.text!,
                      style: const TextStyle(fontSize: 17, color: Colors.black),
                    ),
                  if (richContent != null) richContent!,
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatTime(message.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      if (isSender)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            message.status == 'read'
                                ? Icons.done_all
                                : Icons.done,
                            size: 14,
                            color: message.status == 'read'
                                ? const Color(0xFF4FC3F7)
                                : Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSender)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage(
                    'assets/images/default-avatar.jpg',
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class Message {
  final String? text;
  final DateTime createdAt;
  final String status;
  final String senderId;

  Message({
    this.text,
    required this.createdAt,
    this.status = 'sent',
    required this.senderId,
  });

  factory Message.fromFirestore(Map<String, dynamic> doc) {
    return Message(
      text: doc['text'],
      createdAt: (doc['createdAt'] as Timestamp).toDate(),
      status: doc['status'] ?? 'sent',
      senderId: doc['senderId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (text != null) 'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'senderId': senderId,
    };
  }
}
