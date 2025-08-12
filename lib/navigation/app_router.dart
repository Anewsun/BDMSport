import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/auth/auth_repository.dart';
import '../features/auth/screens/sign_in_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/auth/screens/send_email_screen.dart';
import '../features/chat/screens/chat_list_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/home/screens/filter_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/home/screens/notifications_screen.dart';
import '../features/home/screens/search_result_screen.dart';
import '../features/setting/screens/contact_screen.dart';
import '../features/setting/screens/privacy_policy_screen.dart';
import '../features/setting/screens/setting_screen.dart';
import '../features/setting/screens/profile_screen.dart';
import '../features/favorite/screens/favorite_screen.dart';
import '../features/home/screens/court_detail_screen.dart';
import 'bottom_nav_bar.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authStatusNotifierProvider);

  return GoRouter(
    initialLocation: '/sign-in',
    refreshListenable: authNotifier,
    redirect: (context, state) async {
      final authStatus = authNotifier.value;
      final isAuthRoute = _isAuthRoute(state.matchedLocation);

      if (authStatus == AuthStatus.authenticated && isAuthRoute) {
        return '/home';
      }

      if (authStatus == AuthStatus.unauthenticated && !isAuthRoute) {
        return '/sign-in';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
      GoRoute(path: '/sign-up', builder: (_, _) => const SignUpScreen()),
      GoRoute(path: '/send-email', builder: (_, _) => const SendEmailScreen()),
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      GoRoute(path: '/contact', builder: (_, _) => const ContactScreen()),
      GoRoute(path: '/privacy', builder: (_, _) => const PrivacyPolicyScreen()),
      GoRoute(path: '/filter', builder: (_, _) => const FilterScreen()),
      GoRoute(path: '/search-results', builder: (_, _) => const SearchResultScreen()),
      GoRoute(path: '/court-detail', builder: (_, _) => const CourtDetailScreen()),
      GoRoute(path: '/notification', builder: (_, _) => const NotificationsScreen()),
      GoRoute(
        path: '/chat',
        builder: (_, _) => const ChatScreen(userId: ''),
      ),
      ShellRoute(
        builder: (_, _, child) => BottomNavBar(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          GoRoute(path: '/setting', builder: (_, _) => const SettingScreen()),
          GoRoute(path: '/favorite', builder: (_, _) => const FavoriteScreen()),
          GoRoute(path: '/chat-list', builder: (_, _) => const ChatListScreen()),
        ],
      ),
    ],
    debugLogDiagnostics: true,
  );
});

bool _isAuthRoute(String location) {
  return location == '/sign-in' ||
      location == '/sign-up' ||
      location == '/send-email';
}
