import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_model.dart';
import '../../../core/widgets/date_time_picker_row.dart';
import '../../auth/controllers/sign_in_controller.dart';
import 'voucher_selector.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/models/court_model.dart';
import '../../../core/models/area_model.dart';
import '../../../core/models/voucher_model.dart';

class BookingInfoStep extends ConsumerWidget {
  final Court court;
  final Area area;
  final DateTime startTime;
  final DateTime endTime;
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;
  final VoidCallback onStartTimeTap;
  final VoidCallback onEndTimeTap;
  final List<Voucher> vouchers;
  final Voucher? selectedVoucher;
  final Function(Voucher?) onVoucherSelected;
  final double originalPrice;
  final double finalPrice;
  final bool hasDiscount;
  final bool enabled;

  const BookingInfoStep({
    super.key,
    required this.court,
    required this.area,
    required this.startTime,
    required this.endTime,
    required this.startTimeController,
    required this.endTimeController,
    required this.onStartTimeTap,
    required this.onEndTimeTap,
    required this.vouchers,
    this.selectedVoucher,
    required this.onVoucherSelected,
    required this.originalPrice,
    required this.finalPrice,
    required this.hasDiscount,
    this.enabled = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(signInControllerProvider);
    final user = authState.user;

    final double hours = endTime.difference(startTime).inMinutes / 60.0;
    final double totalOriginalPrice = originalPrice * hours;
    final double totalFinalPrice = finalPrice;
    final bool hasDiscount = totalFinalPrice < totalOriginalPrice;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCourtInfoCard(),
          const SizedBox(height: 24),

          if (user != null) _buildUserInfoSection(user),
          const SizedBox(height: 16),

          DateTimePickerRow(
            label: 'Thời gian bắt đầu',
            dateTime: startTime,
            onDateTap: onStartTimeTap,
            onTimeTap: onStartTimeTap,
            enabled: enabled,
          ),
          const SizedBox(height: 16),
          DateTimePickerRow(
            label: 'Thời gian kết thúc',
            dateTime: endTime,
            onDateTap: onEndTimeTap,
            onTimeTap: onEndTimeTap,
            enabled: enabled,
          ),
          const SizedBox(height: 16),

          VoucherSelector(
            vouchers: vouchers,
            selectedVoucher: selectedVoucher,
            onVoucherSelected: onVoucherSelected,
          ),
          const SizedBox(height: 16),

          _buildPriceDetails(
            totalOriginalPrice: totalOriginalPrice,
            totalFinalPrice: totalFinalPrice,
            hasDiscount: hasDiscount,
            hours: hours,
          ),
        ],
      ),
    );
  }

  Widget _buildCourtInfoCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: area.image.isNotEmpty
                      ? NetworkImage(area.image)
                      : const AssetImage('assets/images/court1.jpg')
                            as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    court.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.location_on, court.address),
                  _buildInfoRow(
                    Icons.sports_tennis,
                    'Khu vực: ${area.nameArea}',
                  ),
                  const SizedBox(height: 8),

                  if (hasDiscount) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          size: 20,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${formatPrice(originalPrice)}/giờ',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 20,
                        color: hasDiscount ? Colors.red : Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tổng: ${formatPrice(finalPrice)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: hasDiscount ? Colors.red : Colors.blue,
                          fontWeight: hasDiscount
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(UserModel user) {
    return Card(
      color: Colors.blue[50],
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin người đặt',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.person, user.name),
            _buildInfoRow(Icons.email, user.email),
            if (user.phone != null && user.phone!.isNotEmpty)
              _buildInfoRow(Icons.phone, user.phone!),
            _buildInfoRow(Icons.workspace_premium, 'Hạng: ${user.tier}'),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDetails({
    required double totalOriginalPrice,
    required double totalFinalPrice,
    required bool hasDiscount,
    required double hours,
  }) {
    return Card(
      color: Colors.green[50],
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chi tiết giá',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Thời gian thuê:'),
                Text('${hours.toStringAsFixed(1)} giờ'),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Giá gốc:'),
                Text(formatPrice(totalOriginalPrice)),
              ],
            ),

            if (hasDiscount) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Giảm giá${selectedVoucher != null ? ' (${selectedVoucher!.code})' : ''}:',
                  ),
                  Text('-${formatPrice(totalOriginalPrice - totalFinalPrice)}'),
                ],
              ),
            ],

            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng tiền:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  formatPrice(totalFinalPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
