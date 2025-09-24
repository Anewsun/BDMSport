import 'package:flutter/material.dart';

class AmenityIcon {
  final IconData icon;
  final Color color;
  final String vietnameseName;

  AmenityIcon(this.icon, this.color, this.vietnameseName);
}

AmenityIcon getAmenityIcon(String amenityName) {
  final normalizedName = amenityName.toLowerCase().trim();

  const amenityIcons = {
    'smoking': [Icons.smoking_rooms, Colors.grey, 'Hút thuốc'],
    'wc': [Icons.wc, Colors.blue, 'Nhà vệ sinh'],
    'net': [Icons.sports, Colors.green, 'Lưới'],
    'pet': [Icons.pets, Colors.brown, 'Thú cưng'],
    'parking': [Icons.local_parking, Colors.blue, 'Bãi đỗ xe'],
    'fan': [Icons.ac_unit, Colors.blue, 'Quạt'],
    'drink': [Icons.local_drink, Colors.blue, 'Đồ uống'],
    'air conditioner': [Icons.ac_unit, Colors.blue, 'Điều hòa'],
    'yard': [Icons.yard, Colors.green, 'Sân vườn'],
    'wifi': [Icons.wifi, Colors.blue, 'Wi-Fi'],
    'food': [Icons.fastfood, Colors.orange, 'Đồ ăn'],
    'children': [Icons.child_care, Colors.pink, 'Khu trẻ em'],
    'light': [Icons.lightbulb, Colors.yellow, 'Đèn chiếu sáng'],
    'carpet': [Icons.carpenter, Colors.brown, 'Thảm'],
    'racket': [Icons.sports_tennis, Colors.green, 'Thuê vợt'],
    'shower': [Icons.shower, Colors.blue, 'Phòng tắm'],
  };

  for (var entry in amenityIcons.entries) {
    if (normalizedName.contains(entry.key)) {
      return AmenityIcon(
        entry.value[0] as IconData,
        entry.value[1] as Color,
        entry.value[2] as String,
      );
    }
  }

  return AmenityIcon(Icons.check_circle, Colors.green, amenityName);
}

extension AmenityIconExtension on String {
  AmenityIcon get amenityIcon => getAmenityIcon(this);
}
