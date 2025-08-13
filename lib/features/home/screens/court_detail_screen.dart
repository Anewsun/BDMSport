import 'package:flutter/material.dart';
import '../../../core/models/court_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/review_form_modal.dart';
import '../widgets/area_search_box.dart';
import '../widgets/court_header.dart';
import '../widgets/court_map.dart';
import '../widgets/court_selection.dart';
import '../widgets/policies_section.dart';
import '../widgets/reviews_section.dart';

class CourtDetailScreen extends StatefulWidget {
  const CourtDetailScreen({super.key});

  @override
  State<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends State<CourtDetailScreen> {
  int? selectedCourtIndex;
  bool showFullDesc = false;
  bool showReviewModal = false;
  bool showAllReviews = false;

  final Map<String, dynamic> court = {
    'id': '1',
    'name': 'Sân cầu lông thể thao Thủ Đức',
    'address': '56 Võ Văn Ngân, Linh Chiểu, Thủ Đức',
    'rating': 3.3,
    'reviewCount': 3,
    'description':
        'Sân cầu lông tiêu chuẩn quốc tế với mặt sân PU cao cấp, hệ thống chiếu sáng LED hiện đại. Sân có 10 lưới tiêu chuẩn, phòng thay đồ rộng rãi và chỗ đậu xe thoải mái.',
    'images': ['assets/images/court1.jpg', 'assets/images/court2.jpg'],
    'amenities': [
      {'icon': Icons.local_parking, 'name': 'Bãi đỗ xe'},
      {'icon': Icons.restaurant, 'name': 'Quán nước'},
      {'icon': Icons.shower, 'name': 'Phòng tắm'},
      {'icon': Icons.shopping_cart, 'name': 'Cửa hàng'},
    ],
    'policies': {
      'checkInTime': '06:00',
      'checkOutTime': '22:00',
      'childrenPolicy': 'Cho phép',
      'petPolicy': 'Không cho phép',
      'smokingPolicy': 'Không cho phép',
    },
  };

  Court _mapToCourt(Map<String, dynamic> map) {
    return Court(
      id: map['id'],
      name: map['name'],
      images: map['images'],
      featuredImage: map['featuredImage'],
    );
  }

  final List<Map<String, dynamic>> availableCourts = [
    {
      'id': '1',
      'name': 'Sân tiêu chuẩn 1',
      'images': ['assets/images/court1.jpg'],
      'price': 150000,
      'discountedPrice': 120000,
      'discountPercent': 20,
      'description': 'Sân tiêu chuẩn Olympic, chất lượng cao',
      'size': '13.4m x 6.1m',
      'type': 'Sân trong nhà',
      'lighting': 'Đèn LED cao cấp',
      'status': 'available',
    },
    {
      'id': '2',
      'name': 'Sân tiêu chuẩn 2',
      'images': ['assets/images/court2.jpg'],
      'price': 180000,
      'discountedPrice': null,
      'discountPercent': 0,
      'description': 'Sân ngoài trời, thoáng mát',
      'size': '13.4m x 6.1m',
      'type': 'Sân ngoài trời',
      'lighting': 'Đèn halogen',
      'status': 'available',
    },
    {
      'id': '3',
      'name': 'Sân quý sờ tộc 2',
      'images': ['assets/images/court3.jpg'],
      'price': 200000,
      'discountedPrice': null,
      'discountPercent': 0,
      'description': 'Sân trong nhà, dụng cụ tốt nhất',
      'size': '13.4m x 6.1m',
      'type': 'Sân trong nhà',
      'lighting': 'Đèn auto nhập khẩu',
      'status': 'available',
    },
  ];

  final List<Map<String, dynamic>> reviews = [
    {
      'rating': 5,
      'title': 'Sân rất tốt',
      'comment': 'Mặt sân đẹp, thoáng mát',
      'date': '08/08/2025',
      'isAnonymous': false,
      'userName': 'Nguyễn Văn A',
      'userImage': 'assets/images/default-avatar.jpg',
      'images': [],
      'isOwner': true,
    },
    {
      'rating': 4,
      'title': 'Hài lòng',
      'comment': 'Giá cả hợp lý, sân ổn định nhưng hơi ồn',
      'date': '05/04/2025',
      'isAnonymous': true,
      'userName': '',
      'userImage': 'assets/images/anonymous.png',
      'images': [],
      'isOwner': false,
    },
    {
      'rating': 1,
      'title': 'Sân tốt',
      'comment': 'Giá cả hợp lý, sân ổn định nhưng thua hơi nhiều nên 1*',
      'date': '05/04/2025',
      'isAnonymous': false,
      'userName': 'Người lạ đi ngang qua',
      'userImage': 'assets/images/default-avatar.jpg',
      'images': [],
      'isOwner': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf0f4ff),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  CourtHeader(court: _mapToCourt(court)),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          court['name'],
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
                                court['address'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            Text(
                              ' ${court['rating']} (${court['reviewCount']} đánh giá)',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'Tiện nghi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: court['amenities'].length,
                            itemBuilder: (context, index) {
                              final amenity = court['amenities'][index];
                              return Container(
                                width: 80,
                                margin: const EdgeInsets.only(right: 16),
                                child: Column(
                                  children: [
                                    Icon(amenity['icon'], size: 30),
                                    const SizedBox(height: 8),
                                    Text(
                                      amenity['name'],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        const Text(
                          'Mô tả',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          court['description'],
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
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        PoliciesSection(policies: court['policies']),
                        const SizedBox(height: 16),

                        const Text(
                          'Vị trí trên bản đồ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const CourtMap(
                          address: '123 Đường Láng, Đống Đa, Hà Nội',
                        ),
                        const SizedBox(height: 16),

                        const AreaSearchBox(),
                        const SizedBox(height: 16),

                        CourtSelection(
                          courts: availableCourts,
                          showAllReviews: showAllReviews,
                          onToggleReviews: () {
                            setState(() {
                              showAllReviews = !showAllReviews;
                            });
                          },
                          onEditReview: () {
                            final ownerReview = reviews.firstWhere(
                              (review) => review['isOwner'] == true,
                              orElse: () => {},
                            );

                            if (ownerReview.isNotEmpty) {
                              setState(() {
                                showReviewModal = true;
                              });
                            }
                          },
                          onDeleteReview: () {},
                          onCourtSelected: (index) {
                            setState(() {
                              selectedCourtIndex = index;
                            });
                          },
                        ),

                        ReviewsSection(
                          reviews: reviews,
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
                          onDeleteReview: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Xóa đánh giá'),
                                content: const Text(
                                  'Bạn có chắc chắn muốn xóa đánh giá này?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Xóa',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            ReviewFormModal(
              visible: showReviewModal,
              isEditing: true,
              review: reviews.firstWhere(
                (review) => review['isOwner'] == true,
                orElse: () => {},
              ),
              onClose: () {
                setState(() {
                  showReviewModal = false;
                });
              },
              onSubmit: () {
                setState(() {
                  showReviewModal = false;
                });
              },
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Giá sân',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (selectedCourtIndex != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (availableCourts[selectedCourtIndex!]['discountedPrice'] !=
                                        null &&
                                    availableCourts[selectedCourtIndex!]['discountedPrice'] <
                                        availableCourts[selectedCourtIndex!]['price'])
                                  Text(
                                    '${formatPrice(availableCourts[selectedCourtIndex!]['price'])}/giờ',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                Text(
                                  '${formatPrice(availableCourts[selectedCourtIndex!]['discountedPrice'] ?? availableCourts[selectedCourtIndex!]['price'])}/giờ',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedCourtIndex != null
                            ? const Color(0xFF1167B1)
                            : Colors.grey,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: selectedCourtIndex != null ? () {} : null,
                      child: const Text(
                        'Đặt sân ngay',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
