import 'package:bdm_sport/core/utils/formatters.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/booking_status_utils.dart';

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onPress;
  final dynamic extraData;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onPress,
    this.extraData,
  });

  String getAreaName() {
    if (booking['area'] == null) return 'Không có thông tin khu vực';
    if (booking['area'] is String) return booking['area'];
    return booking['area']['name'] ??
        booking['area']['areaType'] ??
        'Khu vực không xác định';
  }

  ImageProvider getAreaImageSource() {
    try {
      if (booking['area'] is String) {
        return const AssetImage('assets/images/court1.jpg');
      }

      dynamic firstImage;
      if (booking['area'] != null && booking['area']['images'] != null) {
        firstImage = booking['area']['images'][0];
      }

      final imageUrl =
          firstImage?['url'] ??
          (firstImage is String ? firstImage : null) ??
          booking['area']?['imageUrl'] ??
          booking['area']?['courtId']?['images']?[0]?['url'];

      if (imageUrl != null && imageUrl.toString().isNotEmpty) {
        return NetworkImage(imageUrl.toString());
      }
    } catch (error) {
      debugPrint('Error processing image URL: $error');
    }

    return const AssetImage('assets/images/court1.jpg');
  }

  @override
  Widget build(BuildContext context) {
    final checkIn = DateTime.parse(booking['checkIn']);
    final checkOut = DateTime.parse(booking['checkOut']);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 150,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: getAreaImageSource(),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          getAreaName(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF003366),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: BookingStatusUtils.getStatusColor(
                            booking['status'],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          BookingStatusUtils.getStatusText(booking['status']),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 17,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatDate(checkIn),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF555555),
                            ),
                          ),
                          Text(
                            '${formatTime(checkIn)} - ${formatTime(checkOut)}',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF555555),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${formatDuration(checkIn, checkOut)})',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Người đặt: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            TextSpan(
                              text:
                                  booking['contactInfo']?['name'] ??
                                  'Không có thông tin',
                              style: const TextStyle(color: Colors.black, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      if (booking['bookingFor'] == 'other' &&
                          booking['guestInfo'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Khách ở: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                TextSpan(
                                  text: booking['guestInfo']['name'],
                                  style: TextStyle(color: Color(0xFF444444)),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        formatPrice(booking['finalPrice'] ?? 0),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF003366),
                        ),
                      ),
                      if ((booking['discountAmount'] ?? 0) > 0 &&
                          booking['originalPrice'] != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            formatPrice(booking['originalPrice']),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF999999),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onPress,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Xem chi tiết',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1167B1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: Color(0xFF1167B1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
