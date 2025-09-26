import 'package:flutter/material.dart';
import '../../../core/models/voucher_model.dart';
import '../../../core/utils/formatters.dart';

class VoucherSelector extends StatefulWidget {
  final List<Voucher> vouchers;
  final Function(Voucher?) onVoucherSelected;
  final Voucher? selectedVoucher;

  const VoucherSelector({
    super.key,
    required this.vouchers,
    required this.onVoucherSelected,
    this.selectedVoucher,
  });

  @override
  State<VoucherSelector> createState() => _VoucherSelectorState();
}

class _VoucherSelectorState extends State<VoucherSelector> {
  Voucher? _selectedVoucher;

  @override
  void initState() {
    super.initState();
    _selectedVoucher = widget.selectedVoucher;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn voucher (không bắt buộc)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1.5),
            borderRadius: BorderRadius.circular(25),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Voucher>(
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(25),
              value: _selectedVoucher,
              isExpanded: true,
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Chọn voucher giảm giá'),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              items: [
                const DropdownMenuItem<Voucher>(
                  value: null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Không sử dụng voucher'),
                  ),
                ),
                ...widget.vouchers.map((voucher) {
                  return DropdownMenuItem<Voucher>(
                    value: voucher,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voucher.code,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
              onChanged: (Voucher? voucher) {
                setState(() {
                  _selectedVoucher = voucher;
                });
                widget.onVoucherSelected(voucher);
              },
            ),
          ),
        ),
        if (_selectedVoucher != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.local_offer, color: Colors.green.shade600, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Đã chọn: ${_selectedVoucher!.code} (${_selectedVoucher!.discountType == true ? '${_selectedVoucher!.discount}%' : formatPrice(_selectedVoucher!.discount)})',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.green.shade600,
                    size: 16,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedVoucher = null;
                    });
                    widget.onVoucherSelected(null);
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
