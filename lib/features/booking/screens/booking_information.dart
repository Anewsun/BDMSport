import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/custom_stepper.dart';
import '../widgets/booking_info_step.dart';
import '../widgets/customer_info_step.dart';

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

  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  bool _earlyCheckIn = false;
  bool _lateCheckOut = false;
  String specialRequests = '';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _bookForOthers = false;
  final TextEditingController _guestNameController = TextEditingController();
  final TextEditingController _guestPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startTimeController.text = formatDateTime(_startTime);
    _endTimeController.text = formatDateTime(_endTime);
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _guestNameController.dispose();
    _guestPhoneController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool get _isBookingInfoValid => _endTime.isAfter(_startTime);

  bool get _isCustomerInfoValid {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        !RegExp(r'^\d{10}$').hasMatch(_phoneController.text)) {
      return false;
    }
    if (_bookForOthers) {
      return _guestNameController.text.isNotEmpty &&
          RegExp(r'^\d{10}$').hasMatch(_guestPhoneController.text);
    }
    return true;
  }

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
    }
  }

  void _handleContinue() {
    if (_currentStep == 1 && !_isBookingInfoValid) {
      Fluttertoast.showToast(
        msg: 'Vui lòng chọn thời gian hợp lệ',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.yellow,
        textColor: Colors.black,
        fontSize: 16,
      );
      return;
    }

    if (_currentStep == 2 && !_isCustomerInfoValid) {
      Fluttertoast.showToast(
        msg: 'Vui lòng điền đầy đủ thông tin hợp lệ',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.yellow,
        textColor: Colors.black,
        fontSize: 16,
      );
      return;
    }

    if (_currentStep == 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = 2);
    } else {
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
                  ? 'Thông tin đặt sân'
                  : 'Thông tin khách hàng',
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
              steps: const ['Thông tin đặt sân', 'Xác nhận người đặt'],
              currentStep: _currentStep,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  BookingInfoStep(
                    courtData: _courtData,
                    areaData: _areaData,
                    startTime: _startTime,
                    endTime: _endTime,
                    startTimeController: _startTimeController,
                    endTimeController: _endTimeController,
                    earlyCheckIn: _earlyCheckIn,
                    lateCheckOut: _lateCheckOut,
                    specialRequests: specialRequests,
                    onStartTimeTap: () => _selectDateTime(context, true),
                    onEndTimeTap: () => _selectDateTime(context, false),
                    onEarlyCheckInChanged: (value) =>
                        setState(() => _earlyCheckIn = value),
                    onLateCheckOutChanged: (value) =>
                        setState(() => _lateCheckOut = value),
                    onSpecialRequestsChanged: (value) =>
                        setState(() => specialRequests = value),
                  ),
                  CustomerInfoStep(
                    nameController: _nameController,
                    emailController: _emailController,
                    phoneController: _phoneController,
                    bookForOthers: _bookForOthers,
                    guestNameController: _guestNameController,
                    guestPhoneController: _guestPhoneController,
                    onBookForOthersChanged: (value) =>
                        setState(() => _bookForOthers = value),
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
                      ? (_isBookingInfoValid ? Colors.blue : Colors.grey)
                      : (_isCustomerInfoValid ? Colors.blue : Colors.grey),
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
