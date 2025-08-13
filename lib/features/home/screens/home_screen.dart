import 'package:bdm_sport/core/widgets/search_box.dart';
import 'package:bdm_sport/navigation/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import '../../auth/controllers/sign_in_controller.dart';
import '../widgets/discounted_courts_section.dart';
import '../widgets/notification_icon_with_badge.dart';
import '../widgets/popular_locations_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
    35,
    (index) => {
      '_id': '$index',
      'name': 'Sân cầu lông ${index + 1}',
      'address': 'Quận ${index + 1}',
      'lowestPrice': 150000 + index * 10000,
      'lowestDiscountedPrice': 120000 + index * 10000,
      'highestDiscountPercent': 20,
      'featuredImageUrl':
          'assets/images/court2.jpg',
      'rating': 4.0 + (index % 5) * 0.1,
    },
  );

  int currentPage = 1;
  final int itemsPerPage = 6;
  int get totalPages => (courts.length / itemsPerPage).ceil();

  List<Map<String, dynamic>> get currentPageCourts {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return courts.sublist(
      startIndex,
      endIndex > courts.length ? courts.length : endIndex,
    );
  }

  bool _hasShownToast = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(signInControllerProvider);
    final userName = authState.user?.name ?? 'Khách';

    final loginSuccess = GoRouterState.of(
      context,
    ).uri.queryParameters['loginSuccess'];
    if (!_hasShownToast && loginSuccess == 'true') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Fluttertoast.showToast(
          msg: 'Đăng nhập thành công!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 18,
        );
      });
      _hasShownToast = true;
    }

    ref.listen(signInControllerProvider, (previous, next) {
      if (previous?.user != next.user && mounted) {
        setState(() {});
      }
    });

    return BottomNavBar(
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4FF),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                currentPage = 1;
              });
              return Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 35, 15, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Chào $userName!',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(196, 239, 39, 39),
                              fontFamily: 'Times New Roman',
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.waving_hand, color: Colors.amber),
                        ],
                      ),
                      NotificationIconWithBadge(
                        notificationCount: 3,
                        onPressed: () {
                          context.push('/notification');
                        },
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

                PopularLocationsSection(popularLocations: popularLocations),
                DiscountedCourtsSection(
                  courts: courts,
                  currentPage: currentPage,
                  totalPages: totalPages,
                  onPageChanged: (page) {
                    setState(() => currentPage = page);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
