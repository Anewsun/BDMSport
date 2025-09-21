import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/models/court_model.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/controllers/favorite_controller.dart';
import '../../auth/controllers/sign_in_controller.dart';

class CourtHeader extends ConsumerStatefulWidget {
  final Court court;

  const CourtHeader({super.key, required this.court});

  @override
  ConsumerState<CourtHeader> createState() => _CourtHeaderState();
}

class _CourtHeaderState extends ConsumerState<CourtHeader> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isLoadingFavorite = false;

  List<String> get _images {
    return widget.court.images.isNotEmpty
        ? widget.court.images
        : widget.court.featuredImage != null
        ? [widget.court.featuredImage!]
        : ['assets/images/court4.jpg'];
  }

  Future<void> _toggleFavorite() async {
    final authState = ref.read(signInControllerProvider);
    final userId = authState.user?.id;

    if (userId == null) {
      Fluttertoast.showToast(
        msg: 'Vui lòng đăng nhập để thêm vào danh sách yêu thích',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 18,
      );
      return;
    }

    setState(() {
      _isLoadingFavorite = true;
    });

    try {
      final favoriteController = ref.read(favoriteControllerProvider);
      await favoriteController.toggleFavorite(userId, widget.court.id);

      ref.invalidate(favoriteCourtIdsProvider(userId));
      ref.invalidate(
        isFavoriteProvider((userId: userId, courtId: widget.court.id)),
      );

      Fluttertoast.showToast(
        msg: 'Đã cập nhật danh sách yêu thích',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 18,
      );

      setState(() {});
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Có lỗi xảy ra: ${e.toString()}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 18,
      );
    } finally {
      setState(() {
        _isLoadingFavorite = false;
      });
    }
  }

  void _showFullScreenImage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: Image.network(
                _images[index],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error, color: Colors.red, size: 50),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(signInControllerProvider);
    final userId = authState.user?.id;

    final isFavoriteAsync = userId != null
        ? ref.watch(
            isFavoriteProvider((userId: userId, courtId: widget.court.id)),
          )
        : const AsyncValue.data(false);

    return Stack(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showFullScreenImage(index),
                child: Image.network(
                  _images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.error,
                      color: Colors.grey,
                      size: 50,
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              );
            },
          ),
        ),

        Positioned(
          top: 25,
          left: 0,
          right: 0,
          child: CustomHeader(
            title: '',
            showBackIcon: true,
            onBackPress: () => Navigator.pop(context),
            rightComponent: _isLoadingFavorite
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    onPressed: _toggleFavorite,
                    icon: isFavoriteAsync.when(
                      loading: () => const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      error: (error, stack) =>
                          const Icon(Icons.error, color: Colors.red),
                      data: (isFavorite) => Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
          ),
        ),

        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _images.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index
                      ? Colors.white
                      : const Color.fromRGBO(255, 255, 255, 0.8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
