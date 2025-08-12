import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String? courtName;
  final String? receiverName;

  const ChatScreen({
    super.key,
    required this.userId,
    this.courtName,
    this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isTyping = false;
  bool _socketError = false;
  bool _socketReady = false;
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _simulateSocketConnection();
    _loadMessages();
  }

  void _simulateSocketConnection() async {
    setState(() {
      _socketReady = false;
      _socketError = false;
    });

    await Future.delayed(const Duration(seconds: 1));

    final success = true;

    if (success) {
      setState(() {
        _socketReady = true;
      });
    }
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final dummyMessages = List.generate(10, (index) {
      final isSender = index % 3 == 0;
      final hoursAgo = index * 2;
      final createdAt = DateTime.now().subtract(Duration(hours: hoursAgo));

      return Message(
        text: isSender
            ? 'Đây là tin nhắn từ người $index'
            : 'Rep lại tin của người $index',
        createdAt: createdAt,
        status: isSender ? (index % 2 == 0 ? 'read' : 'sent') : 'sent',
        senderId: isSender ? 'current_user_id' : 'other_user_id',
      );
    });

    setState(() {
      _messages = dummyMessages.reversed.toList();
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _handleSend() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = Message(
      text: text,
      createdAt: DateTime.now(),
      status: 'sent',
      senderId: 'current_user_id',
    );

    setState(() {
      _messages.insert(0, newMessage);
      _messageController.clear();
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _retryConnection() {
    setState(() {
      _socketError = false;
    });
    _simulateSocketConnection();
  }

  @override
  Widget build(BuildContext context) {
    if (_socketError) {
      return _buildErrorScreen();
    }

    if (!_socketReady) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A90E2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.receiverName ?? 'Chủ sân',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.courtName != null)
              Text(
                widget.courtName!,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: const Color(0xFFf0f4ff),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildMessageList(),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadMessages,
        color: const Color(0xFF4A90E2),
        child: ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          itemCount: _messages.length + (_isTyping ? 1 : 0),
          itemBuilder: (context, index) {
            if (_isTyping && index == 0) {
              return _buildTypingIndicator();
            }
      
            final messageIndex = index - (_isTyping ? 1 : 0);
            final message = _messages[messageIndex];
      
            final isSender = message.senderId == 'current_user_id';
            final currentDate = formatDate(message.createdAt);
            final prevDate = messageIndex < _messages.length - 1
                ? formatDate(_messages[messageIndex + 1].createdAt)
                : null;
            final showDate =
                currentDate != prevDate || messageIndex == _messages.length - 1;

            return ChatBubble(
              message: message,
              isSender: isSender,
              showDate: showDate,
            );
          },
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(left: 10),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            'Đang soạn tin nhắn...',
            style: TextStyle(color: Colors.grey[600], fontSize: 17),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 50, maxHeight: 120),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Nhập tin nhắn...',
                  hintStyle: TextStyle(color: Color(0xFF999999)),
                ),
                maxLines: null,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                onChanged: (text) {
                  setState(() {
                    _isTyping = text.isNotEmpty;
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: Icon(
              Icons.send,
              color: _messageController.text.trim().isEmpty
                  ? Colors.grey
                  : const Color(0xFF4A90E2),
            ),
            onPressed: _messageController.text.trim().isEmpty
                ? null
                : _handleSend,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
            ),
            const SizedBox(height: 10),
            const Text(
              'Đang thiết lập kết nối chat...',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            if (_socketError) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _retryConnection,
                child: const Text('THỬ LẠI'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, size: 50, color: Colors.red[400]),
              const SizedBox(height: 10),
              Text(
                'Không thể kết nối với máy chủ chat',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red[400],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: _retryConnection,
                child: const Text(
                  'THỬ LẠI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
