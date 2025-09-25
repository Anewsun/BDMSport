import 'package:flutter/material.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/utils/formatters.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final Function(String) onPressed;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.status == NotificationStatus.unread;
    final iconInfo = getIconInfo(notification.type);

    return GestureDetector(
      onTap: () => onPressed(notification.id!),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.1),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
          border: isUnread
              ? Border(left: BorderSide(color: Colors.blue, width: 4))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconInfo.bg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(iconInfo.icon, size: 25, color: iconInfo.color),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatTime(notification.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconInfo getIconInfo(NotificationType type) {
  final icons = {
    NotificationType.booking: IconInfo(
      icon: Icons.event_available,
      bg: const Color(0xFFE8F5E9),
      color: const Color(0xFF4CAF50),
    ),
    NotificationType.voucher: IconInfo(
      icon: Icons.local_offer,
      bg: const Color(0xFFF3E5F5),
      color: const Color(0xFF9C27B0),
    ),
    NotificationType.admin: IconInfo(
      icon: Icons.admin_panel_settings,
      bg: const Color(0xFFE3F2FD),
      color: const Color(0xFF2196F3),
    ),
    NotificationType.payment: IconInfo(
      icon: Icons.payment,
      bg: const Color(0xFFFBE9E7),
      color: const Color(0xFFD84315),
    ),
  };

  return icons[type] ??
      IconInfo(
        icon: Icons.notifications,
        bg: const Color(0xFFF5F5F5),
        color: const Color(0xFF9E9E9E),
      );
}

class IconInfo {
  final IconData icon;
  final Color color;
  final Color bg;

  IconInfo({required this.icon, required this.color, required this.bg});
}
