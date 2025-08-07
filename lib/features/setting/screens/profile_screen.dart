import 'package:bdm_sport/features/setting/controllers/setting_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
          .updateUserInfo(
            userId: currentUser.id,
            updatedData: updatedData,
          );

      _loadUserData();
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
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
                  onBackPress: () => context.pop(),
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
                    TierSection(tier: user.tier, balance: user.balance),
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
