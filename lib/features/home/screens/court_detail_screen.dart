import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/controllers/court_controller.dart';
import '../../../core/controllers/review_controller.dart';
import '../../../core/models/court_model.dart';
import '../../../core/models/area_model.dart';
import '../../../core/models/review_model.dart';
import '../../../core/utils/amenity_icons.dart';
import '../../../core/widgets/review_form_modal.dart';
import '../widgets/area_search_box.dart';
import '../widgets/booking_bar.dart';
import '../widgets/court_header.dart';
import '../widgets/court_map.dart';
import '../widgets/court_selection.dart';
import '../widgets/policies_section.dart';
import '../widgets/reviews_section.dart';

class CourtDetailScreen extends ConsumerStatefulWidget {
  final String courtId;
  final DateTime? initialStartTime;
  final DateTime? initialEndTime;

  const CourtDetailScreen({
    super.key,
    required this.courtId,
    this.initialStartTime,
    this.initialEndTime,
  });

  @override
  ConsumerState<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends ConsumerState<CourtDetailScreen> {
  int? selectedAreaIndex;
  bool showFullDesc = false;
  bool showReviewModal = false;
  bool showAllReviews = false;
  Review? userReview;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late DateTime _checkInDate;
  late DateTime _checkOutDate;

  @override
  void initState() {
    super.initState();
    _checkInDate = widget.initialStartTime ?? DateTime.now();
    _checkOutDate =
        widget.initialEndTime ?? DateTime.now().add(const Duration(hours: 1));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserReview();
    });
  }

  void _loadUserReview() async {
    try {
      final reviewController = ref.read(reviewControllerProvider);
      final review = await reviewController.getUserReviewForCourt(
        widget.courtId,
      );
      setState(() {
        userReview = review;
      });
    } catch (e) {
      setState(() {
        userReview = null;
      });
    }
  }

  void _refreshData() {
    ref.invalidate(courtFutureProvider(widget.courtId));
    ref.invalidate(areasFutureProvider(widget.courtId));
    ref.invalidate(courtReviewsFutureProvider(widget.courtId));
    _loadUserReview();
  }

  void _onSearchChanged(DateTime startTime, DateTime endTime) {
    setState(() {
      _checkInDate = startTime;
      _checkOutDate = endTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    final courtStream = ref.watch(courtStreamProvider(widget.courtId));
    final areasStream = ref.watch(areasStreamProvider(widget.courtId));
    final reviewsAsync = ref.watch(courtReviewsFutureProvider(widget.courtId));

    return Scaffold(
      backgroundColor: const Color(0xFFf0f4ff),
      body: SafeArea(
        child: Stack(
          children: [
            courtStream.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Lỗi: $error')),
              data: (court) => areasStream.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Lỗi: $error')),
                data: (areas) => reviewsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Lỗi: $error')),
                  data: (reviews) => _buildContent(court, areas, reviews),
                ),
              ),
            ),

            ReviewFormModal(
              visible: showReviewModal,
              isEditing: userReview != null,
              review: userReview != null
                  ? {
                      'rating': userReview!.rating,
                      'title': userReview!.title,
                      'comment': userReview!.comment,
                      'isAnonymous': userReview!.isAnonymous,
                    }
                  : null,
              onClose: () {
                setState(() {
                  showReviewModal = false;
                });
              },
              onSubmit: (reviewData) async {
                try {
                  final reviewController = ref.read(reviewControllerProvider);
                  if (userReview != null) {
                    await reviewController.updateReview(
                      userReview!.id!,
                      reviewData['rating'],
                      reviewData['title'],
                      reviewData['comment'],
                      reviewData['isAnonymous'],
                    );
                    Fluttertoast.showToast(
                      msg: 'Cập nhật đánh giá thành công!',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 18,
                    );
                  } else {
                    await reviewController.createReview(
                      widget.courtId,
                      reviewData['rating'],
                      reviewData['title'],
                      reviewData['comment'],
                      reviewData['isAnonymous'],
                    );
                    Fluttertoast.showToast(
                      msg: 'Thêm đánh giá thành công!',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 18,
                    );
                  }

                  _refreshData();
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: "Lỗi: ${e.toString()}",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 18,
                  );
                }
                setState(() {
                  showReviewModal = false;
                });
              },
            ),

            areasStream.when(
              loading: () => Container(),
              error: (error, stack) => Container(),
              data: (areas) => Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BookingBar(
                  areas: areas,
                  selectedAreaIndex: selectedAreaIndex,
                  onBookPressed: () {
                    context.push(
                      '/booking-step',
                      extra: {
                        'courtId': widget.courtId,
                        'areaId': areas[selectedAreaIndex!].id,
                        'area': areas[selectedAreaIndex!],
                        'court': courtStream.value,
                        'startTime': _checkInDate,
                        'endTime': _checkOutDate,
                      },
                    );
                  },
                  isEnabled: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Court court, List<Area> areas, List<Review> reviews) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CourtHeader(court: court),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  court.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 20),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        court.address,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                StreamBuilder<DocumentSnapshot<Court>>(
                  stream: _db
                      .collection('courts')
                      .doc(widget.courtId)
                      .withConverter<Court>(
                        fromFirestore: (snap, _) => Court.fromFirestore(snap),
                        toFirestore: (court, _) => court.toMap(),
                      )
                      .snapshots(),
                  builder: (context, snapshot) {
                    final courtRating = snapshot.hasData
                        ? snapshot.data!.data()?.rating ?? 0.0
                        : court.rating;

                    return Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        Text(
                          ' $courtRating (${reviews.length} đánh giá)',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                const Text(
                  'Tiện nghi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: court.amenities.length,
                    itemBuilder: (context, index) {
                      final amenityName = court.amenities[index];
                      final amenityIcon = getAmenityIcon(amenityName);
                      return Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            Icon(
                              amenityIcon.icon,
                              size: 30,
                              color: amenityIcon.color,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              amenityIcon.vietnameseName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const Text(
                  'Mô tả',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  court.description,
                  maxLines: showFullDesc ? null : 3,
                  overflow: showFullDesc ? null : TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showFullDesc = !showFullDesc;
                    });
                  },
                  child: Text(
                    showFullDesc ? 'Thu gọn' : 'Xem thêm...',
                    style: const TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),

                PoliciesSection(policies: court.policies),
                const SizedBox(height: 16),

                const Text(
                  'Vị trí trên bản đồ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                CourtMap(address: court.address),
                const SizedBox(height: 16),

                AreaSearchBox(
                  onSearchChanged: _onSearchChanged,
                  initialStartTime: _checkInDate,
                  initialEndTime: _checkOutDate,
                ),
                const SizedBox(height: 16),

                CourtSelection(
                  areas: areas,
                  showAllReviews: showAllReviews,
                  onToggleReviews: () {
                    setState(() {
                      showAllReviews = !showAllReviews;
                    });
                  },
                  onEditReview: () {
                    setState(() {
                      showReviewModal = true;
                    });
                  },
                  onDeleteReview: () async {
                    if (userReview != null) {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xóa đánh giá'),
                          content: const Text(
                            'Bạn có chắc chắn muốn xóa đánh giá này?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Xóa',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        try {
                          final reviewController = ref.read(
                            reviewControllerProvider,
                          );
                          await reviewController.deleteReview(userReview!.id!);

                          _refreshData();

                          Fluttertoast.showToast(
                            msg: 'Xóa đánh giá thành công!',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            fontSize: 18,
                          );
                        } catch (e) {
                          Fluttertoast.showToast(
                            msg: "Lỗi: ${e.toString()}",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                      }
                    }
                  },
                  onCourtSelected: (index) {
                    setState(() {
                      selectedAreaIndex = index;
                    });
                  },
                ),

                ReviewsSection(
                  reviews: reviews.map((r) {
                    final map = r.toMap();
                    final currentUserId =
                        FirebaseAuth.instance.currentUser?.uid;
                    final isOwner = r.userId == currentUserId;
                    return {...map, 'isOwner': isOwner};
                  }).toList(),
                  showAllReviews: showAllReviews,
                  onToggleReviews: () {
                    setState(() {
                      showAllReviews = !showAllReviews;
                    });
                  },
                  onEditReview: () {
                    setState(() {
                      showReviewModal = true;
                    });
                  },
                  onDeleteReview: () async {
                    if (userReview != null) {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xóa đánh giá'),
                          content: const Text(
                            'Bạn có chắc chắn muốn xóa đánh giá này?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Xóa',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        try {
                          final reviewController = ref.read(
                            reviewControllerProvider,
                          );
                          await reviewController.deleteReview(userReview!.id!);

                          _refreshData();

                          Fluttertoast.showToast(
                            msg: 'Xóa đánh giá thành công!',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            fontSize: 18,
                          );
                        } catch (e) {
                          Fluttertoast.showToast(
                            msg: "Lỗi: ${e.toString()}",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                      }
                    }
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
