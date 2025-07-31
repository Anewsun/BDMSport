import 'package:bdm_sport/core/widgets/court_card.dart';
import 'package:bdm_sport/core/widgets/popular_location_card.dart';
import 'package:bdm_sport/core/widgets/search_box.dart';
import 'package:bdm_sport/navigation/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> popularLocations = [
    {
      '_id': '1',
      'name': 'Quận 1',
      'imageUrl':
          'https://lh7-us.googleusercontent.com/RpJsZJpUE7GiSnl6q-zehT1zgdRPVzkYRkzBnfvhq3CRQQaLmZzuxDFq2uLRhlgXEOpQusxAbKRLNsOD5ygXGoO0y0hKGA5s3AKz89G957hGLv20SBiwcIgiAzSrCMXCepOlO6pMkokJkzVA1M212tA',
      'courtCount': 8,
    },
    {
      '_id': '2',
      'name': 'Tân Bình',
      'imageUrl':
          'https://toptphochiminhaz.com/wp-content/uploads/2024/12/cho-tan-binh_5.jpg',
      'courtCount': 5,
    },
    {
      '_id': '3',
      'name': 'Phú Nhuận',
      'imageUrl':
          'https://maisonoffice.vn/wp-content/uploads/2024/04/1-gioi-thieu-tong-quan-ve-quan-phu-nhuan-tphcm.jpg',
      'courtCount': 3,
    },
    {
      '_id': '4',
      'name': 'Thủ Đức',
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Ch%E1%BB%A3_Th%E1%BB%A7_%C4%90%E1%BB%A9c.jpg/250px-Ch%E1%BB%A3_Th%E1%BB%A7_%C4%90%E1%BB%A9c.jpg',
      'courtCount': 6,
    },
  ];

  final List<Map<String, dynamic>> courts = List.generate(
    8,
    (index) => {
      '_id': '$index',
      'name': 'Sân cầu lông ${index + 1}',
      'address': 'Quận ${index + 1}',
      'lowestPrice': 150000 + index * 10000,
      'lowestDiscountedPrice': 120000 + index * 10000,
      'highestDiscountPercent': 20,
      'featuredImageUrl':
          'https://source.unsplash.com/random/300x200?badminton,$index',
      'rating': 4.0 + (index % 5) * 0.1,
    },
  );

  int currentPage = 1;
  int get totalPages => (courts.length / 6).ceil();

  @override
  Widget build(BuildContext context) {
    final paginatedCourts = courts.skip((currentPage - 1) * 6).take(6).toList();

    return BottomNavBar(
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4FF),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async =>
                Future.delayed(const Duration(milliseconds: 500)),
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(15, 35, 15, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Chào Lương Võ Nhật Tân!',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(196, 239, 39, 39),
                              fontFamily: 'Times New Roman',
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(Icons.waving_hand, color: Colors.amber),
                        ],
                      ),
                      Stack(
                        children: [
                          Icon(
                            Icons.notifications,
                            color: Colors.blueGrey,
                            size: 35,
                          ),
                          Positioned(
                            right: 6,
                            top: 6,
                            child: CircleAvatar(
                              radius: 7,
                              backgroundColor: Colors.red,
                              child: Text(
                                '1',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontFamily: 'Times New Roman',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Bắt đầu đặt sân ngay nào!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Times New Roman',
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: SearchBox(),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 25, 15, 10),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Color(0xFFFFD700)),
                      const SizedBox(width: 8),
                      Text(
                        'Địa điểm có nhiều sân nhất',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Times New Roman',
                          color: Color(0xFFFFD700),
                          shadows: [
                            Shadow(
                              blurRadius: 6,
                              color: Colors.brown,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    scrollDirection: Axis.horizontal,
                    itemCount: popularLocations.length,
                    itemBuilder: (_, index) {
                      final location = popularLocations[index];
                      return PopularLocationCard(
                        imageUrl: location['imageUrl'],
                        name: location['name'],
                        courtCount: location['courtCount'],
                        onTap: () {},
                      );
                    },
                  ),
                ),

                Container(
                  color: Colors.black.withOpacity(0.02),
                  padding: const EdgeInsets.fromLTRB(15, 25, 15, 10),
                  child: Text(
                    'Sân đang có giảm giá',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Times New Roman',
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [Colors.red, Colors.yellow, Colors.orange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(const Rect.fromLTWH(0, 0, 250, 40)),
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black.withOpacity(0.6),
                          offset: const Offset(1, 1),
                        ),
                        Shadow(
                          blurRadius: 10,
                          color: Colors.red,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: paginatedCourts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.55,
                        ),
                    itemBuilder: (_, index) {
                      final court = paginatedCourts[index];
                      return CourtCard(
                        court: court,
                        onTap: () {},
                        isFavorite: false,
                        onToggleFavorite: () {},
                        showDiscountBadge: true,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    totalPages,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentPage == index + 1
                              ? const Color(0xFF1167B1)
                              : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() => currentPage = index + 1);
                        },
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontFamily: 'Times New Roman',
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
