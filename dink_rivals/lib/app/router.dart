import 'package:go_router/go_router.dart';

import '../screens/end_match_screen.dart';
import '../screens/game_screen.dart';
import '../screens/main_menu_screen.dart';
import '../screens/roster_screen.dart';
import '../screens/settings_screen.dart';

class AppRoutes {
  static const menu = '/';
  static const game = '/game';
  static const settings = '/settings';
  static const roster = '/roster';
  static const endMatch = '/end-match';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.menu,
  routes: [
    GoRoute(
      path: AppRoutes.menu,
      builder: (context, state) => const MainMenuScreen(),
    ),
    GoRoute(
      path: AppRoutes.game,
      builder: (context, state) => const GameScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.roster,
      builder: (context, state) => const RosterScreen(),
    ),
    GoRoute(
      path: AppRoutes.endMatch,
      builder: (context, state) => const EndMatchScreen(),
    ),
  ],
);
