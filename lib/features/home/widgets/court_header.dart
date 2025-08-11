import 'package:flutter/material.dart';
import '../../../core/models/court_model.dart';
import '../../../core/widgets/custom_header.dart';

class CourtHeader extends StatefulWidget {
  final Court court;

  const CourtHeader({super.key, required this.court});

  @override
  State<CourtHeader> createState() => _CourtHeaderState();
}

class _CourtHeaderState extends State<CourtHeader> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isFavorite = false;

  List<String> get _images {
    return widget.court.images?.isNotEmpty ?? false
        ? widget.court.images!
        : widget.court.featuredImage != null
            ? [widget.court.featuredImage!]
            : [
                'assets/images/court1.jpg',
                'assets/images/court2.jpg',
              ];
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
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
              child: Image.asset(
                _images[index],
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                child: Image.asset(
                  _images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
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
            rightComponent: IconButton(
              onPressed: _toggleFavorite,
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.blueGrey,
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
                      : Color.fromRGBO(255, 255, 255, 0.8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
