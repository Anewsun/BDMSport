import 'package:flutter/material.dart';
import '../../../core/widgets/date_time_picker_row.dart';
import 'court_info_card.dart';
import 'voucher_selector.dart';

class BookingInfoStep extends StatelessWidget {
  final Map<String, dynamic> courtData;
  final Map<String, dynamic> areaData;
  final DateTime startTime;
  final DateTime endTime;
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;
  final VoidCallback onStartTimeTap;
  final VoidCallback onEndTimeTap;
  final List<Voucher> vouchers;
  final Voucher? selectedVoucher;
  final Function(Voucher?) onVoucherSelected;
  final double? originalPrice;
  final double? finalPrice;
  final bool enabled;

  const BookingInfoStep({
    super.key,
    required this.courtData,
    required this.areaData,
    required this.startTime,
    required this.endTime,
    required this.startTimeController,
    required this.endTimeController,
    required this.onStartTimeTap,
    required this.onEndTimeTap,
    required this.vouchers,
    this.selectedVoucher,
    required this.onVoucherSelected,
    this.originalPrice,
    this.finalPrice,
    this.enabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CourtInfoCard(
            courtData: courtData,
            areaData: areaData,
            originalPrice: originalPrice,
            finalPrice: finalPrice,
            showPriceComparison: true,
          ),
          const SizedBox(height: 24),
          DateTimePickerRow(
            label: 'Thời gian bắt đầu',
            dateTime: startTime,
            onDateTap: onStartTimeTap,
            onTimeTap: onStartTimeTap,
            enabled: enabled
          ),
          const SizedBox(height: 16),
          DateTimePickerRow(
            label: 'Thời gian kết thúc',
            dateTime: endTime,
            onDateTap: onEndTimeTap,
            onTimeTap: onEndTimeTap,
            enabled: enabled
          ),
          const SizedBox(height: 16),
          VoucherSelector(
            vouchers: vouchers,
            selectedVoucher: selectedVoucher,
            onVoucherSelected: onVoucherSelected,
          ),
        ],
      ),
    );
  }
}
