import 'package:flutter/material.dart';

class CustomerInfoStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final bool bookForOthers;
  final TextEditingController guestNameController;
  final TextEditingController guestPhoneController;
  final ValueChanged<bool> onBookForOthersChanged;

  const CustomerInfoStep({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.bookForOthers,
    required this.guestNameController,
    required this.guestPhoneController,
    required this.onBookForOthersChanged,
  });

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
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: phoneController,
            decoration: InputDecoration(
              labelText: 'Số điện thoại',
              border: const OutlineInputBorder(),
              errorText:
                  phoneController.text.isNotEmpty &&
                      !RegExp(r'^\d{10}$').hasMatch(phoneController.text)
                  ? 'Số điện thoại phải có 10 chữ số'
                  : null,
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Đặt sân cho người khác'),
            value: bookForOthers,
            onChanged: onBookForOthersChanged,
            activeColor: Colors.blue,
          ),
          if (bookForOthers) ...[
            const SizedBox(height: 16),
            const Text(
              'Thông tin người chơi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: guestNameController,
              decoration: const InputDecoration(
                labelText: 'Họ và tên người chơi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: guestPhoneController,
              decoration: InputDecoration(
                labelText: 'Số điện thoại người chơi',
                border: const OutlineInputBorder(),
                errorText:
                    guestPhoneController.text.isNotEmpty &&
                        !RegExp(r'^\d{10}$').hasMatch(guestPhoneController.text)
                    ? 'Số điện thoại phải có 10 chữ số'
                    : null,
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ],
      ),
    );
  }
}
