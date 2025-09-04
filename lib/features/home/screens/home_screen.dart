import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/court_model.dart';
import '../../../core/widgets/pagination_controls.dart';
import '../../../core/widgets/search_box.dart';
import '../../../navigation/bottom_nav_bar.dart';
import '../../auth/controllers/sign_in_controller.dart';
import '../../court/controllers/court_controller.dart';
import '../widgets/discounted_courts_section.dart';
import '../widgets/notification_icon_with_badge.dart';
import '../widgets/popular_locations_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int currentPage = 1;
  final int itemsPerPage = 6;
  bool _hasShownToast = false;
  late List<Court> _allCourts = [];
  bool _isLoading = true;
  bool _isDiscounted = true;

  late ProviderSubscription<AuthState> _subscription;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCourts();

    _subscription = ref.listenManual<AuthState>(signInControllerProvider, (
      previous,
      next,
    ) {
      if (previous?.user != next.user && mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _loadCourts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final courtController = ref.read(courtControllerProvider);
      // Lấy sân giảm giá trước
      final discountedCourts = await courtController.getDiscountedCourts();

      if (discountedCourts.isNotEmpty) {
        _allCourts = discountedCourts;
        _isDiscounted = true;
      } else {
        // Nếu không có sân giảm giá, lấy sân thường
        final regularCourts = await courtController.getActiveCourts();
        _allCourts = regularCourts;
        _isDiscounted = false;
      }
    } catch (e) {
      _allCourts = [];
      _isDiscounted = false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Court> get _currentPageCourts {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return _allCourts.sublist(
      startIndex,
      endIndex > _allCourts.length ? _allCourts.length : endIndex,
    );
  }

  int get _totalPages {
    return (_allCourts.length / itemsPerPage).ceil();
  }

  void _handlePageChange(int newPage) {
    setState(() {
      currentPage = newPage;
    });
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _subscription.close();
    _scrollController.dispose();
    super.dispose();
  }

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

    return BottomNavBar(
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4FF),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                currentPage = 1;
              });
              await _loadCourts();
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
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
                ),

                SliverToBoxAdapter(
                  child: const Padding(
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
                ),

                SliverToBoxAdapter(
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: SearchBox(),
                  ),
                ),

                SliverToBoxAdapter(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: ref
                        .read(courtControllerProvider)
                        .getTopLocationsWithCourts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.hasError) {
                        return PopularLocationsSection(locations: []);
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return PopularLocationsSection(locations: []);
                      }

                      final locations = snapshot.data!;
                      return PopularLocationsSection(locations: locations);
                    },
                  ),
                ),

                SliverToBoxAdapter(
                  child: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : DiscountedCourtsSection(
                          courts: _currentPageCourts,
                          isDiscounted: _isDiscounted,
                        ),
                ),

                if (!_isLoading && _allCourts.isNotEmpty && _totalPages > 1)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: PaginationControls(
                        currentPage: currentPage,
                        totalPages: _totalPages,
                        onPageChanged: _handlePageChange,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
