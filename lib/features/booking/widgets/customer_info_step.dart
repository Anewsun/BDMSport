import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/sign_in_controller.dart';

class CustomerInfoStep extends ConsumerStatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final VoidCallback onValidationChanged;
  final bool validateAll;

  const CustomerInfoStep({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.onValidationChanged,
    this.validateAll = false,
  });

  @override
  ConsumerState<CustomerInfoStep> createState() => _CustomerInfoStepState();
}

class _CustomerInfoStepState extends ConsumerState<CustomerInfoStep> {
  bool _nameTouched = false;
  bool _emailTouched = false;
  bool _phoneTouched = false;
  bool _userDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(signInControllerProvider);
      if (authState.user != null && !_userDataLoaded) {
        setState(() {
          if (widget.nameController.text.isEmpty) {
            widget.nameController.text = authState.user!.name;
          }
          if (widget.emailController.text.isEmpty) {
            widget.emailController.text = authState.user!.email;
          }
          if (widget.phoneController.text.isEmpty &&
              authState.user!.phone != null) {
            widget.phoneController.text = authState.user!.phone!;
          }
          _userDataLoaded = true;
        });
        widget.onValidationChanged();
      }
    });
  }

  @override
  void didUpdateWidget(CustomerInfoStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.validateAll && !oldWidget.validateAll) {
      setState(() {
        _nameTouched = true;
        _emailTouched = true;
        _phoneTouched = true;
      });
      widget.onValidationChanged();
    }
  }

  String? get _nameError {
    if (_nameTouched && widget.nameController.text.isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    return null;
  }

  String? get _emailError {
    if (_emailTouched) {
      if (widget.emailController.text.isEmpty) {
        return 'Vui lòng nhập email';
      }
      if (!RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      ).hasMatch(widget.emailController.text)) {
        return 'Email không hợp lệ';
      }
    }
    return null;
  }

  String? get _phoneError {
    if (_phoneTouched) {
      if (widget.phoneController.text.isEmpty) {
        return 'Vui lòng nhập số điện thoại';
      }
      if (!RegExp(r'^\d{10}$').hasMatch(widget.phoneController.text)) {
        return 'Số điện thoại phải có 10 chữ số';
      }
    }
    return null;
  }

  bool get isValid {
    return _nameError == null && _emailError == null && _phoneError == null;
  }

  void _onFieldChanged() {
    setState(() {});
    widget.onValidationChanged();
  }

  void _onFieldTouched(String field) {
    setState(() {
      switch (field) {
        case 'name':
          _nameTouched = true;
        case 'email':
          _emailTouched = true;
        case 'phone':
          _phoneTouched = true;
      }
    });
    widget.onValidationChanged();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin người đặt',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.nameController,
            decoration: InputDecoration(
              labelText: 'Họ và tên',
              border: const OutlineInputBorder(),
              errorText: _nameError,
              errorMaxLines: 2,
            ),
            onChanged: (value) => _onFieldChanged(),
            onTap: () => _onFieldTouched('name'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: const OutlineInputBorder(),
              errorText: _emailError,
              errorMaxLines: 2,
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => _onFieldChanged(),
            onTap: () => _onFieldTouched('email'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.phoneController,
            decoration: InputDecoration(
              labelText: 'Số điện thoại',
              border: const OutlineInputBorder(),
              errorText: _phoneError,
              errorMaxLines: 2,
            ),
            keyboardType: TextInputType.phone,
            onChanged: (value) => _onFieldChanged(),
            onTap: () => _onFieldTouched('phone'),
          ),
        ],
      ),
    );
  }
}
