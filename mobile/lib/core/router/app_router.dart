import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/live_page.dart';
import '../../features/fantasy/presentation/pages/squad_page.dart';
import '../../features/fantasy/presentation/pages/transfers_page.dart';
import '../../features/prediction/presentation/pages/leaderboard_page.dart';
import '../localization/app_localizations.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login', // Updated route name for consistency
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final target = state.uri.queryParameters['target'] ?? '';
          return OtpPage(target: target);
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/squad',
            builder: (context, state) => const SquadPage(),
          ),
          GoRoute(
            path: '/transfers',
            builder: (context, state) => const TransfersPage(),
          ),
          GoRoute(
            path: '/leaderboard',
            builder: (context, state) => const LeaderboardPage(),
          ),
          GoRoute(
            path: '/live',
            builder: (context, state) => const LivePage(),
          ),
        ],
      ),
    ],
  );
}

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/squad')) return 1;
    if (location.startsWith('/transfers')) return 2;
    if (location.startsWith('/leaderboard')) return 3;
    if (location.startsWith('/live')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/squad');
        break;
      case 2:
        context.go('/transfers');
        break;
      case 3:
        context.go('/leaderboard');
        break;
      case 4:
        context.go('/live');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(index, context),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: localizations?.translate('home') ?? 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.sports_soccer),
            label: localizations?.translate('my_squad') ?? 'Squad',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.swap_horiz),
            label: localizations?.translate('transfers') ?? 'Transfers',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.leaderboard),
            label: localizations?.translate('leaderboard') ?? 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.live_tv),
            label: localizations?.translate('live') ?? 'Live',
          ),
        ],
      ),
    );
  }
}
