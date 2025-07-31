import 'package:go_router/go_router.dart';

import '../features/auth/screens/sign_in_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/auth/screens/send_email_screen.dart';
import '../features/auth/screens/verify_code_screen.dart';
import '../features/auth/screens/new_password_screen.dart';
import '../features/home/screens/home_screen.dart';
// import '../features/home/screens/favorite_screen.dart';
// import '../features/home/screens/booking_screen.dart';
// import '../features/home/screens/blog_list_screen.dart';
// import '../features/home/screens/chat_list_screen.dart';
import '../features/setting/screens/contact_screen.dart';
import '../features/setting/screens/privacy_policy_screen.dart';
import '../features/setting/screens/setting_screen.dart';
import '../features/setting/screens/profile_screen.dart';
import 'bottom_nav_bar.dart';

final GoRouter router = GoRouter(
  initialLocation: '/sign-in',
  routes: [
    // --- AUTH ROUTES ---
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/sign-up',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/send-email',
      builder: (context, state) => const SendEmailScreen(),
    ),
    GoRoute(
      path: '/verify-code',
      builder: (context, state) => const VerifyCodeScreen(),
    ),
    GoRoute(
      path: '/new-password',
      builder: (context, state) => const NewPasswordScreen(email: '', otp: ''),
    ),

    // --- PROFILE (KHÔNG CÓ BOTTOM NAV) ---
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/contact',
      builder: (context, state) => const ContactScreen(),
    ),
    GoRoute(
      path: '/privacy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),

    // --- SHELL ROUTES (BOTTOM NAV CHỈ CHO NHÓM NÀY) ---
    ShellRoute(
      builder: (context, state, child) {
        return BottomNavBar(child: child);
      },
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        // GoRoute(path: '/favorite', builder: (context, state) => const FavoriteScreen()),
        // GoRoute(path: '/booking', builder: (context, state) => const BookingScreen()),
        // GoRoute(path: '/chats', builder: (context, state) => const ChatListScreen()),
        GoRoute(
          path: '/setting',
          builder: (context, state) => const SettingScreen(),
        ),
      ],
    ),
  ],
);
