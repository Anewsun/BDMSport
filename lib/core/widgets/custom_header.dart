import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPress;
  final bool showBackIcon;
  final Widget? rightComponent;

  const CustomHeader({
    super.key,
    required this.title,
    this.onBackPress,
    this.showBackIcon = true,
    this.rightComponent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 19, left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 40,
            child: showBackIcon
                ? IconButton(
                    onPressed: onBackPress,
                    icon: const Icon(
                      Ionicons.arrow_back,
                      size: 28,
                      color: Colors.black,
                    ),
                  )
                : const SizedBox(),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 40, child: rightComponent ?? const SizedBox()),
        ],
      ),
    );
  }
}
