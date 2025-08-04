import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/screens/sign_in_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/auth/screens/send_email_screen.dart';
import '../features/auth/screens/verify_code_screen.dart';
import '../features/auth/screens/new_password_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/setting/screens/contact_screen.dart';
import '../features/setting/screens/privacy_policy_screen.dart';
import '../features/setting/screens/setting_screen.dart';
import '../features/setting/screens/profile_screen.dart';
import 'bottom_nav_bar.dart';
import '../core/auth/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/sign-in',
    redirect: (context, state) async {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.user != null;
      final isAuthRoute = _isAuthRoute(state.matchedLocation);

      // Nếu đang loading, không redirect
      if (authState.isLoading) return null;

      if (isLoggedIn && isAuthRoute) return '/home';
      if (!isLoggedIn && !isAuthRoute) return '/sign-in';

      return null;
    },
    routes: [
      GoRoute(path: '/sign-in', builder: (_, __) => const SignInScreen()),
      GoRoute(path: '/sign-up', builder: (_, __) => const SignUpScreen()),
      GoRoute(path: '/send-email', builder: (_, __) => const SendEmailScreen()),
      GoRoute(
        path: '/verify-code',
        builder: (_, __) => const VerifyCodeScreen(),
      ),
      GoRoute(
        path: '/new-password',
        builder: (_, __) => const NewPasswordScreen(email: '', otp: ''),
      ),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/contact', builder: (_, __) => const ContactScreen()),
      GoRoute(path: '/privacy', builder: (_, _) => const PrivacyPolicyScreen()),
      ShellRoute(
        builder: (_, __, child) => BottomNavBar(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/setting', builder: (_, __) => const SettingScreen()),
        ],
      ),
    ],
    debugLogDiagnostics: true,
  );
});

bool _isAuthRoute(String location) {
  return location == '/sign-in' ||
      location == '/sign-up' ||
      location == '/send-email' ||
      location == '/verify-code' ||
      location == '/new-password';
}
