import 'package:flutter/material.dart';

class ProfileSection extends StatelessWidget {
  final String name, email, phone, address;
  final bool emailChanged;
  final VoidCallback onSave;

  const ProfileSection({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.emailChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin cơ bản',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildInput(Icons.person, name, false),
          if (emailChanged)
            const Padding(
              padding: EdgeInsets.only(left: 32, bottom: 8),
              child: Text(
                'Email sẽ cần được xác thực lại sau khi thay đổi',
                style: TextStyle(color: Colors.redAccent, fontSize: 14),
              ),
            ),
          _buildInput(Icons.mail, email, false),
          _buildInput(Icons.phone, phone, false),
          _buildInput(Icons.location_pin, address, false),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff1167B1),
            ),
            onPressed: onSave,
            child: const Text(
              'Lưu thay đổi',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Times New Roman',
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(IconData icon, String value, bool obscure) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff1167B1)),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              initialValue: value,
              obscureText: obscure,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xfff9f9f9),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
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
