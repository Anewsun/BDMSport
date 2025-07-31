import 'package:flutter/material.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../widgets/profile_section.dart';
import '../widgets/tier_section.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool loading = false;

  // dummy user data
  final Map<String, dynamic> user = {
    'name': 'Lương Võ Nhật Tân',
    'email': 'tan@gmail.com',
    'phone': '0123456789',
    'address': '123 Đường ABC',
    'tier': 'Silver',
    'balance': 2500000,
  };

  bool emailChanged = false;

  @override
  void initState() {
    super.initState();
    // load user data etc.
  }

  void onSaveChanges() {
    // TODO: gọi API cập nhật
    setState(() => loading = true);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cập nhật thông tin thành công!')));
    });
  }

  void onDeactivate() {
    // TODO: show modal và gọi API
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f4ff),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: CustomHeader(
                    title: 'Thông tin cá nhân',
                    showBackIcon: true,
                    onBackPress: () => context.pop(),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 20),
                    children: [
                      ProfileSection(
                        name: user['name']!,
                        email: user['email']!,
                        phone: user['phone']!,
                        address: user['address']!,
                        emailChanged: emailChanged,
                        onSave: onSaveChanges,
                      ),
                      TierSection(
                        tier: user['tier']!,
                        balance: user['balance']!,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (loading) const LoadingOverlay(),
          ],
        ),
      ),
    );
  }
}
