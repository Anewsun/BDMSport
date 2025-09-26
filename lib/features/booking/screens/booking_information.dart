import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/custom_stepper.dart';
import '../widgets/booking_info_step.dart';
import '../widgets/customer_info_step.dart';
import '../widgets/voucher_selector.dart';

class BadmintonCourtBookingScreen extends StatefulWidget {
  const BadmintonCourtBookingScreen({super.key});

  @override
  BadmintonCourtBookingScreenState createState() =>
      BadmintonCourtBookingScreenState();
}

class BadmintonCourtBookingScreenState
    extends State<BadmintonCourtBookingScreen> {
  int _currentStep = 1;
  final PageController _pageController = PageController();

  final Map<String, dynamic> _courtData = {
    'name': 'Sân cầu lông Hồ Chí Minh',
    'address': '123 Đường Lê Lợi, Quận 1',
    'imageUrl': 'assets/images/court3.jpg',
  };

  final Map<String, dynamic> _areaData = {
    'name': 'Khu vực VIP',
    'price': 150000,
    'imageUrl': null,
  };

  final List<Voucher> _vouchers = [
    Voucher(
      id: '1',
      code: 'GIAM20K',
      name: 'Giảm 20K',
      description: 'Giảm 20.000đ cho đơn từ 100.000đ',
      discountValue: 20000,
      discountType: 'fixed',
      minOrderValue: 100000,
    ),
    Voucher(
      id: '2',
      code: 'GIAM10%',
      name: 'Giảm 10%',
      description: 'Giảm 10% tối đa 50.000đ',
      discountValue: 10,
      discountType: 'percentage',
      maxDiscount: 50000,
    ),
    Voucher(
      id: '3',
      code: 'HOTDEAL',
      name: 'Giảm 30%',
      description: 'Giảm 30% cho khách hàng mới',
      discountValue: 30,
      discountType: 'percentage',
      maxDiscount: 100000,
    ),
  ];

  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Voucher? _selectedVoucher;
  double _originalPrice = 150000.0;
  double _finalPrice = 15000.0;

  bool _validateAllFields = false;

  @override
  void initState() {
    super.initState();
    _startTimeController.text = formatDateTime(_startTime);
    _endTimeController.text = formatDateTime(_endTime);
    _calculatePrice();
  }

  bool get _isCustomerInfoValid {
    return _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(_emailController.text) &&
        _phoneController.text.isNotEmpty &&
        RegExp(r'^\d{10}$').hasMatch(_phoneController.text);
  }

  void _onValidationChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _calculatePrice() {
    final double hours = _endTime.difference(_startTime).inMinutes / 60.0;
    double totalPrice = _originalPrice * hours;

    if (_selectedVoucher != null) {
      double discount = 0;

      if (_selectedVoucher!.discountType == 'percentage') {
        discount = totalPrice * (_selectedVoucher!.discountValue / 100);
        if (_selectedVoucher!.maxDiscount != null &&
            discount > _selectedVoucher!.maxDiscount!) {
          discount = _selectedVoucher!.maxDiscount!;
        }
      } else {
        discount = _selectedVoucher!.discountValue;
      }

      if (_selectedVoucher!.minOrderValue == null ||
          totalPrice >= _selectedVoucher!.minOrderValue!) {
        totalPrice -= discount;
        if (totalPrice < 0) totalPrice = 0;
      }
    }

    setState(() {
      _finalPrice = totalPrice / hours;
    });
  }

  void _onVoucherSelected(Voucher? voucher) {
    setState(() {
      _selectedVoucher = voucher;
    });
    _calculatePrice();
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool get _isBookingInfoValid => _endTime.isAfter(_startTime);

  Future<void> _selectDateTime(BuildContext context, bool isStartTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartTime ? _startTime : _endTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (!mounted || pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStartTime ? _startTime : _endTime),
    );

    if (!mounted || pickedTime == null) return;

    final DateTime newDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (mounted) {
      setState(() {
        if (isStartTime) {
          _startTime = newDateTime;
          _startTimeController.text = formatDateTime(_startTime);
          if (_endTime.isBefore(_startTime) || _endTime == _startTime) {
            _endTime = _startTime.add(const Duration(hours: 1));
            _endTimeController.text = formatDateTime(_endTime);
          }
        } else {
          _endTime = newDateTime;
          _endTimeController.text = formatDateTime(_endTime);
        }
      });
      _calculatePrice();
    }
  }

  void _handleContinue() {
    if (_currentStep == 1) {
      setState(() {
        _validateAllFields = true;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isCustomerInfoValid) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          setState(() => _currentStep = 2);
        } else {
          Fluttertoast.showToast(
            msg: 'Vui lòng điền đầy đủ thông tin hợp lệ',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.yellow,
            textColor: Colors.black,
            fontSize: 16,
          );
        }
      });
    } else if (_currentStep == 2 && !_isBookingInfoValid) {
      Fluttertoast.showToast(
        msg: 'Vui lòng chọn thời gian hợp lệ',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.yellow,
        textColor: Colors.black,
        fontSize: 16,
      );
      return;
    } else if (_currentStep == 2) {
      _showConfirmationDialog();
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đặt sân'),
        content: const Text('Bạn có chắc chắn muốn đặt sân này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: 'Đặt sân thành công!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 18,
              );
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4FF),
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: _currentStep == 1
                  ? 'Thông tin khách hàng'
                  : 'Thông tin đặt sân',
              onBackPress: () {
                if (_currentStep == 1) {
                  Navigator.pop(context);
                } else {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  setState(() => _currentStep = 1);
                }
              },
              showBackIcon: true,
            ),
            CustomStepper(
              steps: const ['Xác nhận người đặt', 'Thông tin đặt sân'],
              currentStep: _currentStep,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  CustomerInfoStep(
                    nameController: _nameController,
                    emailController: _emailController,
                    phoneController: _phoneController,
                    onValidationChanged: _onValidationChanged,
                    validateAll: _validateAllFields,
                  ),
                  BookingInfoStep(
                    courtData: _courtData,
                    areaData: _areaData,
                    startTime: _startTime,
                    endTime: _endTime,
                    startTimeController: _startTimeController,
                    endTimeController: _endTimeController,
                    onStartTimeTap: () => _selectDateTime(context, true),
                    onEndTimeTap: () => _selectDateTime(context, false),
                    vouchers: _vouchers,
                    selectedVoucher: _selectedVoucher,
                    onVoucherSelected: _onVoucherSelected,
                    originalPrice: _originalPrice,
                    finalPrice: _finalPrice,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _handleContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentStep == 1
                      ? (_isCustomerInfoValid ? Colors.blue : Colors.grey)
                      : (_isBookingInfoValid ? Colors.blue : Colors.grey),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  _currentStep == 1 ? 'Tiếp tục' : 'Xác nhận đặt sân',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
