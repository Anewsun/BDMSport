import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/controllers/sign_in_controller.dart';
import '../features/auth/screens/sign_in_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/auth/screens/send_email_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/setting/screens/contact_screen.dart';
import '../features/setting/screens/privacy_policy_screen.dart';
import '../features/setting/screens/setting_screen.dart';
import '../features/setting/screens/profile_screen.dart';
import 'bottom_nav_bar.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(signInControllerProvider.notifier);

  return GoRouter(
    initialLocation: '/sign-in',
    redirect: (context, state) async {
      final authState = ref.read(signInControllerProvider);
      final isLoggedIn = authState.user != null;
      final isAuthRoute = _isAuthRoute(state.matchedLocation);

      if (authState.isLoading) return null;

      if (isLoggedIn && isAuthRoute) return '/home';
      if (!isLoggedIn && !isAuthRoute) return '/sign-in';

      return null;
    },
    routes: [
      GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
      GoRoute(path: '/sign-up', builder: (_, _) => const SignUpScreen()),
      GoRoute(path: '/send-email', builder: (_, _) => const SendEmailScreen()),
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      GoRoute(path: '/contact', builder: (_, _) => const ContactScreen()),
      GoRoute(path: '/privacy', builder: (_, _) => const PrivacyPolicyScreen()),
      ShellRoute(
        builder: (_, _, child) => BottomNavBar(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          GoRoute(path: '/setting', builder: (_, _) => const SettingScreen()),
        ],
      ),
    ],
    refreshListenable: authNotifier,
    debugLogDiagnostics: true,
  );
});

bool _isAuthRoute(String location) {
  return location == '/sign-in' ||
      location == '/sign-up' ||
      location == '/send-email';
}
