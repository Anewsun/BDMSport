import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/widgets/custom_header.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  String? expandedItem;

  final List<Map<String, String>> contactItems = [
    {
      'icon': 'headset_mic',
      'title': 'Chăm sóc khách hàng',
      'content': 'Luôn hiện diện 24/7',
    },
    {'icon': 'phone_android', 'title': 'WhatsApp', 'content': 'BDMSportApp'},
    {
      'icon': 'language',
      'title': 'Website',
      'content': 'https://badmintonsport.com/',
    },
    {'icon': 'facebook', 'title': 'Facebook', 'content': 'facebook.com/abc'},
    {
      'icon': 'camera_alt',
      'title': 'Instagram',
      'content': 'instagram.com/abc',
    },
  ];

  void toggleItem(String title) {
    setState(() {
      expandedItem = expandedItem == title ? null : title;
    });
  }

  void handleLinkPress(String url) async {
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  Widget renderContent(String content, String title) {
    final isLink =
        title == 'Website' || title == 'Facebook' || title == 'Instagram';
    return Padding(
      padding: const EdgeInsets.only(left: 56, right: 16, bottom: 16),
      child: TextButton(
        onPressed: isLink ? () => handleLinkPress(content) : null,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
        ),
        child: Text(
          content,
          style: TextStyle(
            fontSize: 18,
            color: isLink ? Colors.blue : Colors.black,
            decoration: isLink ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: CustomHeader(
                title: 'Thông tin về chúng tôi',
                showBackIcon: true,
                onBackPress: () => context.pop(),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: contactItems.length,
                itemBuilder: (context, index) {
                  final item = contactItems[index];
                  return InkWell(
                    onTap: () => toggleItem(item['title']!),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                _getMaterialIcon(item['icon']!),
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  item['title']!,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Icon(
                                expandedItem == item['title']
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                        if (expandedItem == item['title'])
                          renderContent(item['content']!, item['title']!),
                        const Divider(height: 1, color: Color(0xFFE0E0E0)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMaterialIcon(String iconName) {
    switch (iconName) {
      case 'headset_mic':
        return Icons.headset_mic;
      case 'phone_android':
        return Icons.phone_android;
      case 'language':
        return Icons.language;
      case 'facebook':
        return Icons.facebook;
      case 'camera_alt':
        return Icons.camera_alt;
      default:
        return Icons.info;
    }
  }
}
