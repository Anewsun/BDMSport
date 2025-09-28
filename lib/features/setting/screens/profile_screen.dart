import 'package:bdm_sport/features/setting/controllers/setting_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/controllers/paypal_controller.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../widgets/profile_section.dart';
import '../widgets/tier_section.dart';
import '../../auth/controllers/sign_in_controller.dart';
import '../../../core/models/user_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool loading = false;
  late UserModel user;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUser = ref.read(signInControllerProvider).user;
    if (currentUser != null) {
      setState(() {
        user = currentUser;
        _initialized = true;
      });
    }
  }

  void onSaveChanges(Map<String, dynamic> updatedData) async {
    final currentUser = ref.read(signInControllerProvider).user;
    if (currentUser == null) return;

    setState(() => loading = true);

    try {
      await ref
          .read(settingControllerProvider.notifier)
          .updateUserInfo(userId: currentUser.id, updatedData: updatedData);

      _loadUserData();
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<int?> _showDepositDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.account_balance_wallet, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text("Nạp tiền", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Số tiền (VNĐ)",
                hintText: "Ví dụ: 100000",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.money, color: Colors.green),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final amount = int.tryParse(controller.text.trim());
              if (amount != null && amount > 0) {
                Navigator.pop(context, amount);
              }
            },
            icon: const Icon(Icons.check_circle),
            label: const Text("Xác nhận"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return LoadingOverlay(
      isLoading: loading,
      child: Scaffold(
        backgroundColor: const Color(0xfff0f4ff),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: CustomHeader(
                  title: 'Thông tin cá nhân',
                  showBackIcon: true,
                  onBackPress: () {
                    context.go('/setting');
                  },
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 20),
                  children: [
                    ProfileSection(
                      name: user.name,
                      email: user.email,
                      phone: user.phone ?? '',
                      address: user.address ?? '',
                      onSave: onSaveChanges,
                    ),

                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(user.id)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        final balance = data["balance"] ?? 0;
                        final tier = data["tier"] ?? user.tier;
                        final doubleBalance = (balance as num).toDouble();

                        return TierSection(tier: tier, balance: doubleBalance);
                      },
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 220),
                        child: ElevatedButton(
                          onPressed: () async {
                            final amount = await _showDepositDialog(context);
                            if (amount != null) {
                              await PaymentController().depositWithPayPal(
                                context,
                                amount,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            "Nạp tiền ngay",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
