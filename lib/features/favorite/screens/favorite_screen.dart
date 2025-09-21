import 'package:bdm_sport/navigation/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/court_card.dart';
import '../../../core/widgets/custom_header.dart';
import '../../auth/controllers/sign_in_controller.dart';
import '../../../core/controllers/favorite_controller.dart';
import '../../../core/models/court_model.dart';

class FavoriteScreen extends ConsumerStatefulWidget {
  const FavoriteScreen({super.key});

  @override
  ConsumerState<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends ConsumerState<FavoriteScreen> {
  List<Court> _favoriteCourts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteCourts();
  }

  Future<void> _loadFavoriteCourts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authState = ref.read(signInControllerProvider);
      final userId = authState.user?.id;

      if (userId != null) {
        final favoriteController = ref.read(favoriteControllerProvider);
        final courts = await favoriteController.getFavoriteCourts(userId);
        setState(() {
          _favoriteCourts = courts;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Có lỗi khi tải danh sách yêu thích: ${e.toString()}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 18,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleToggleFavorite(String courtId) async {
    final authState = ref.read(signInControllerProvider);
    final userId = authState.user?.id;

    if (userId == null) {
      Fluttertoast.showToast(
        msg: 'Vui lòng đăng nhập để thực hiện thao tác này',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 18,
      );
      return;
    }

    try {
      final favoriteController = ref.read(favoriteControllerProvider);
      await favoriteController.toggleFavorite(userId, courtId);

      Fluttertoast.showToast(
        msg: 'Đã xóa khỏi danh sách yêu thích',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 18,
      );

      ref.invalidate(favoriteCourtIdsProvider(userId));

      await _loadFavoriteCourts();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Có lỗi xảy ra: ${e.toString()}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 18,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(signInControllerProvider);
    final userId = authState.user?.id;

    return BottomNavBar(
      child: Scaffold(
        backgroundColor: const Color(0xFFf0f4ff),
        body: SafeArea(
          child: Column(
            children: [
              CustomHeader(title: 'Danh sách yêu thích', showBackIcon: false),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _favoriteCourts.isEmpty || userId == null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            userId == null
                                ? "Vui lòng đăng nhập để xem danh sách yêu thích"
                                : "Chưa có sân nào được thêm vào danh sách, hãy chọn sân mà bạn muốn thêm vào đây nhé!",
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
                        itemCount: _favoriteCourts.length,
                        itemBuilder: (context, index) {
                          final court = _favoriteCourts[index];

                          final map = <String, dynamic>{
                            'name': court.name,
                            'address': court.address,
                            'featuredImageUrl': court.featuredImage,
                            'rating': court.rating,
                            'lowestPrice': court.lowestPrice,
                            'lowestDiscountedPrice':
                                court.lowestDiscountedPrice,
                            'highestDiscountPercent':
                                court.highestDiscountPercent,
                          };

                          return CourtCard(
                            court: map,
                            isFavorite: true,
                            onToggleFavorite: () =>
                                _handleToggleFavorite(court.id),
                            onTap: () {
                              context.push('/court-detail/${court.id}');
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
