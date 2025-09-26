import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/custom_stepper.dart';
import '../../auth/controllers/sign_in_controller.dart';
import '../widgets/booking_info_step.dart';
import '../widgets/customer_info_step.dart';
import '../../../core/controllers/booking_controller.dart';
import '../../../core/controllers/voucher_controller.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/models/court_model.dart';
import '../../../core/models/area_model.dart';
import '../../../core/models/voucher_model.dart';

class BadmintonCourtBookingScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> bookingData;

  const BadmintonCourtBookingScreen({super.key, required this.bookingData});

  @override
  ConsumerState<BadmintonCourtBookingScreen> createState() =>
      _BadmintonCourtBookingScreenState();
}

class _BadmintonCourtBookingScreenState
    extends ConsumerState<BadmintonCourtBookingScreen> {
  int _currentStep = 1;
  final PageController _pageController = PageController();
  bool _isLoading = false;

  late DateTime _startTime;
  late DateTime _endTime;
  late String _areaId;

  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Voucher? _selectedVoucher;
  double _originalPrice = 0.0;
  double _finalPrice = 0.0;
  List<Voucher> _availableVouchers = [];

  bool _validateAllFields = false;
  late Court _court;
  late Area _area;

  @override
  void initState() {
    super.initState();

    _court = widget.bookingData['court'] as Court;
    _area = widget.bookingData['area'] as Area;
    _startTime = widget.bookingData['startTime'] as DateTime;
    _endTime = widget.bookingData['endTime'] as DateTime;
    _areaId = widget.bookingData['areaId'] as String? ?? _area.id!;

    _originalPrice = _area.discountPercent > 0
        ? _area.discountedPrice
        : _area.price;
    _finalPrice =
        _originalPrice * _endTime.difference(_startTime).inMinutes / 60.0;

    _startTimeController.text = formatDateTime(_startTime);
    _endTimeController.text = formatDateTime(_endTime);

    _calculatePrice();
    _loadAvailableVouchers();
    _loadUserData();
  }

  void _loadUserData() {
    final authState = ref.read(signInControllerProvider);
    final user = authState.user;

    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          if (_nameController.text.isEmpty) {
            _nameController.text = user.name;
          }
          if (_emailController.text.isEmpty) {
            _emailController.text = user.email;
          }
          if (_phoneController.text.isEmpty && user.phone != null) {
            _phoneController.text = user.phone!;
          }
        });
      });
    }
  }

  void _loadAvailableVouchers() async {
    try {
      final authState = ref.read(signInControllerProvider);
      final user = authState.user;

      if (user == null) return;

      final voucherController = VoucherController();
      final vouchers = await voucherController.getAvailableVouchers(
        userId: user.id,
        userTier: user.tier,
        orderValue: _finalPrice,
      );
      setState(() {
        _availableVouchers = vouchers;
      });
    } catch (e) {
      print('❌ Lỗi khi load voucher: $e');
    }
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

      if (_selectedVoucher!.discountType == true) {
        // percentage = true
        discount = totalPrice * (_selectedVoucher!.discount / 100);
        if (discount > _selectedVoucher!.maxDiscount) {
          discount = _selectedVoucher!.maxDiscount;
        }
      } else {
        // fixed amount = false
        discount = _selectedVoucher!.discount;
      }

      if (totalPrice >= _selectedVoucher!.minOrderValue) {
        totalPrice -= discount;
        if (totalPrice < 0) totalPrice = 0;
      }
    }

    setState(() {
      _finalPrice = totalPrice;
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
    final authState = ref.read(signInControllerProvider);
    final user = authState.user;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Xác nhận đặt sân'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Người đặt: ${user?.name ?? _nameController.text}'),
            Text('SĐT: ${user?.phone ?? _phoneController.text}'),
            Text('Sân: ${_court.name}'),
            Text('Khu vực: ${_area.nameArea}'),
            Text(
              'Thời gian: ${formatDateTime(_startTime)} - ${formatDateTime(_endTime)}',
            ),
            Text('Tổng tiền: ${formatPrice(_finalPrice)}'),
            if (_selectedVoucher != null)
              Text('Voucher: ${_selectedVoucher!.code}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => _createBooking(),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  Future<void> _createBooking() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final authState = ref.read(signInControllerProvider);
      final user = authState.user;
      if (user == null) throw Exception('User chưa đăng nhập');

      final bookingController = BookingController();

      final isAvailable = await bookingController.checkAreaAvailability(
        areaId: _areaId,
        checkIn: _startTime,
        checkOut: _endTime,
      );

      if (!isAvailable) {
        Fluttertoast.showToast(msg: 'Khu vực này đã được đặt...');
        return;
      }

      final double hours = _endTime.difference(_startTime).inMinutes / 60.0;
      final double totalOriginalPrice = _originalPrice * hours;

      final booking = Booking(
        userId: user.id,
        areaId: _areaId,
        contactInfo: {
          'name': _nameController.text.isNotEmpty
              ? _nameController.text
              : user.name,
          'email': _emailController.text.isNotEmpty
              ? _emailController.text
              : user.email,
          'phone': _phoneController.text.isNotEmpty
              ? _phoneController.text
              : (user.phone ?? ''),
        },
        checkIn: _startTime,
        checkOut: _endTime,
        voucherId: _selectedVoucher?.id,
        originalPrice: totalOriginalPrice,
        discountAmount: _selectedVoucher != null
            ? totalOriginalPrice - _finalPrice
            : 0,
        finalPrice: _finalPrice,
        status: 'pending',
        paymentStatus: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final bookingId = await bookingController.createBooking(booking);

      if (bookingId != null) {
        if (_selectedVoucher != null) {
          await bookingController.applyVoucherToBooking(
            voucherId: _selectedVoucher!.id,
            userId: user.id,
            bookingId: bookingId,
          );
        }

        if (mounted) {
          Navigator.pop(context);

          Fluttertoast.showToast(
            msg: 'Đặt sân thành công',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 18,
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go('/booking-list');
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: 'Lỗi khi đặt sân: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
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
                    court: _court,
                    area: _area,
                    startTime: _startTime,
                    endTime: _endTime,
                    startTimeController: _startTimeController,
                    endTimeController: _endTimeController,
                    onStartTimeTap: () => _selectDateTime(context, true),
                    onEndTimeTap: () => _selectDateTime(context, false),
                    vouchers: _availableVouchers,
                    selectedVoucher: _selectedVoucher,
                    onVoucherSelected: _onVoucherSelected,
                    originalPrice: _originalPrice,
                    finalPrice: _finalPrice,
                    hasDiscount: _selectedVoucher != null,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLoading
                      ? Colors.grey
                      : (_currentStep == 1
                            ? (_isCustomerInfoValid ? Colors.blue : Colors.grey)
                            : (_isBookingInfoValid
                                  ? Colors.blue
                                  : Colors.grey)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        _currentStep == 1 ? 'Tiếp tục' : 'Xác nhận đặt sân',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
