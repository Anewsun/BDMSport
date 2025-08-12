import 'package:flutter/material.dart';

class NotificationIconWithBadge extends StatelessWidget {
  final int notificationCount;
  final VoidCallback? onPressed;

  const NotificationIconWithBadge({
    super.key,
    required this.notificationCount,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          onPressed ??
          () {
            Navigator.pushNamed(context, '/notification');
          },
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.notifications, color: Colors.blueGrey, size: 35),
          if (notificationCount > 0)
            Positioned(
              right: 6,
              top: 6,
              child: CircleAvatar(
                radius: 7,
                backgroundColor: Colors.red,
                child: Text(
                  notificationCount.toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontFamily: 'Times New Roman',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
