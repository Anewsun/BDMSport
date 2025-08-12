import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../navigation/bottom_nav_bar.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final List<Map<String, dynamic>> conversations = [
    {
      '_id': '1',
      'courtName': 'Sân cầu lông Mỹ Tho',
      'avatar': 'assets/images/default-avatar.jpg',
      'lastMessage': 'Xin chào, tôi muốn đặt sân, có thể tư vấn cho tôi không',
      'lastMessageDate': DateTime.now().subtract(const Duration(minutes: 30)),
      'unreadCount': 2,
    },
    {
      '_id': '2',
      'courtName': 'Sân cầu lông Đạo Thạnh',
      'avatar': 'assets/images/default-avatar.jpg',
      'lastMessage': 'Cảm ơn bạn đã đặt sân',
      'lastMessageDate': DateTime.now().subtract(const Duration(hours: 2)),
      'unreadCount': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: BottomNavBar(
          child: Column(
            children: [
              CustomHeader(title: 'Tin nhắn', showBackIcon: false),
              Expanded(
                child: conversations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              size: 60,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Chưa có tin nhắn',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Hãy chat với chủ sân nào đó để hiện danh sách nhé!',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: conversations.length,
                        itemBuilder: (context, index) {
                          final item = conversations[index];
                          return ChatItem(
                            item: item,
                            onTap: () {
                              context.push('/chat');
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const ChatItem({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
        ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: item['avatar'] != null
                  ? CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage(item['avatar']),
                    )
                  : Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90E2),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(
                        Icons.account_circle,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['courtName'] ?? 'Sân cầu lông',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatDate(item['lastMessageDate']),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.lightBlueAccent,
                            ),
                          ),
                          Text(
                            formatTime(item['lastMessageDate']),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['lastMessage'] ?? '',
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if ((item['unreadCount'] ?? 0) > 0)
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    item['unreadCount'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
