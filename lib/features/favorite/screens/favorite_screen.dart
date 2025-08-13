import 'package:bdm_sport/navigation/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/court_card.dart';
import '../../../core/widgets/custom_header.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> favoriteCourts = [
      {
        '_id': '1',
        'name': 'Sân bóng đá AAAAAAAAAA',
        'address': '123 Đường ABC, Quận 1',
        'rating': 4.5,
        'lowestPrice': 200000,
        'lowestDiscountedPrice': 180000,
        'highestDiscountPercent': 10,
        'featuredImageUrl': 'assets/images/court4.jpg',
      },
      {
        '_id': '2',
        'name': 'Sân bóng đá B',
        'address': '456 Đường XYZ, Quận 2',
        'rating': 4.2,
        'lowestPrice': 250000,
        'lowestDiscountedPrice': 220000,
        'highestDiscountPercent': 12,
        'featuredImageUrl':
            'assets/images/court3.jpg',
      },
    ];

    return BottomNavBar(
      child: Scaffold(
        backgroundColor: const Color(0xFFf0f4ff),
        body: SafeArea(
          child: Column(
            children: [
              CustomHeader(title: 'Danh sách yêu thích', showBackIcon: false),
              Expanded(
                child: favoriteCourts.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Chưa có sân nào được thêm vào danh sách, hãy chọn sân mà bạn muốn thêm vào đây nhé!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 20,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.6,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                            ),
                        itemCount: favoriteCourts.length,
                        itemBuilder: (context, index) {
                          final court = favoriteCourts[index];
                          return CourtCard(
                            court: court,
                            isFavorite: true,
                            onToggleFavorite: () {},
                            onTap: () {
                              context.push('/court-detail');
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
