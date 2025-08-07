import 'package:flutter/material.dart';

class ProfileSection extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String address;
  final Function(Map<String, dynamic>) onSave;

  const ProfileSection({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.onSave,
  });

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isEditing = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _phoneController = TextEditingController(text: widget.phone);
    _addressController = TextEditingController(text: widget.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      _autoValidate = false;
      if (!_isEditing) {
        _nameController.text = widget.name;
        _phoneController.text = widget.phone;
        _addressController.text = widget.address;
      }
    });
  }

  void _saveChanges() {
    setState(() => _autoValidate = true);
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
      };
      widget.onSave(updatedData);
      setState(() => _isEditing = false);
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Số điện thoại phải có 10 chữ số';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Form(
        key: _formKey,
        autovalidateMode: _autoValidate
            ? AutovalidateMode.always
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin cơ bản',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildInput(
              Icons.person,
              _nameController,
              'Họ và tên',
              _isEditing,
              _validateName,
            ),
            _buildInput(
              Icons.mail,
              TextEditingController(text: widget.email),
              'Email',
              false,
              null,
            ),
            _buildInput(
              Icons.phone,
              _phoneController,
              'Số điện thoại',
              _isEditing,
              _validatePhone,
            ),
            _buildInput(
              Icons.location_pin,
              _addressController,
              'Địa chỉ',
              _isEditing,
              null
            ),
            const SizedBox(height: 8),
            _isEditing
                ? Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff1167B1),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: _saveChanges,
                          child: const Text(
                            'Lưu thay đổi',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Times New Roman',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xff1167B1)),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: _toggleEditing,
                          child: const Text(
                            'Hủy',
                            style: TextStyle(
                              color: Color(0xff1167B1),
                              fontFamily: 'Times New Roman',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1167B1),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _toggleEditing,
                    child: const Text(
                      'Chỉnh sửa thông tin',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Times New Roman',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(
    IconData icon,
    TextEditingController controller,
    String label,
    bool editable,
    String? Function(String?)? validator,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff1167B1), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              enabled: editable,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
                filled: true,
                fillColor: const Color(0xfff9f9f9),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                errorStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
