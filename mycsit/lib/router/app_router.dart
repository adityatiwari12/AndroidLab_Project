import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/home/home_shell.dart';
import '../features/dashboard/dashboard_tab.dart';
import '../features/activities/activity_list_tab.dart';
import '../features/activities/add_activity_sheet.dart';
import '../features/activities/activity_detail_screen.dart';
import '../features/coding/coding_screen.dart';
import '../features/profile/profile_tab.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/academics/academics_screen.dart';
import '../features/rank/my_rank_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.read(authProvider);

  return GoRouter(
    refreshListenable: auth,
    initialLocation: '/login',
    redirect: (context, state) {
      final loggedIn = auth.isLoggedIn;
      final path = state.uri.path;
      final isAuth = path == '/login' || path == '/register';

      if (!loggedIn && !isAuth) return '/login';
      if (loggedIn && isAuth) return '/home/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (_, __, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/home/dashboard',
            builder: (_, __) => const DashboardTab(),
          ),
          GoRoute(
            path: '/home/timeline',
            builder: (_, __) => const ActivityListTab(),
          ),
          GoRoute(
            path: '/home/profile',
            builder: (_, __) => const ProfileTab(),
          ),
          GoRoute(
            path: '/home/notifications',
            builder: (_, __) => const NotificationsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/rank',
        builder: (_, __) => const MyRankScreen(),
      ),
      GoRoute(
        path: '/academics',
        builder: (_, __) => const AcademicsScreen(),
      ),
      GoRoute(
        path: '/coding',
        builder: (_, __) => const CodingScreen(),
      ),
      GoRoute(
        path: '/activities/:id',
        builder: (_, state) =>
            ActivityDetailScreen(id: state.pathParameters['id']!),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
});
