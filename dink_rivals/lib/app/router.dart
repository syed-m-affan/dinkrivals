import 'package:go_router/go_router.dart';

import '../screens/debug_rally_screen.dart';
import '../screens/end_match_screen.dart';
import '../screens/game_screen.dart';
import '../screens/main_menu_screen.dart';
import '../screens/court_select_screen.dart';
import '../screens/roster_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/tournament_screen.dart';
import '../screens/trophy_room_screen.dart';

class AppRoutes {
  static const menu = '/';
  static const game = '/game';
  static const debugRally = '/debug-rally';
  static const settings = '/settings';
  static const roster = '/roster';
  static const courts = '/courts';
  static const endMatch = '/end-match';
  static const tournament = '/tournament';
  static const trophyRoom = '/trophy-room';
}

const String _qaInitialRoute = String.fromEnvironment(
  'DINK_RIVALS_INITIAL_ROUTE',
  defaultValue: AppRoutes.menu,
);

final appRouter = createAppRouter(initialLocation: _qaInitialRoute);

GoRouter createAppRouter({String initialLocation = AppRoutes.menu}) {
  return GoRouter(
    initialLocation: _normalizedInitialLocation(initialLocation),
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
        path: AppRoutes.debugRally,
        builder: (context, state) => const DebugRallyScreen(),
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
        path: AppRoutes.courts,
        builder: (context, state) => const CourtSelectScreen(),
      ),
      GoRoute(
        path: AppRoutes.tournament,
        builder: (context, state) => const TournamentScreen(),
      ),
      GoRoute(
        path: AppRoutes.trophyRoom,
        builder: (context, state) => const TrophyRoomScreen(),
      ),
      GoRoute(
        path: AppRoutes.endMatch,
        builder: (context, state) => const EndMatchScreen(),
      ),
    ],
  );
}

String _normalizedInitialLocation(String initialLocation) {
  return switch (initialLocation) {
    AppRoutes.menu ||
    AppRoutes.game ||
    AppRoutes.debugRally ||
    AppRoutes.settings ||
    AppRoutes.roster ||
    AppRoutes.courts ||
    AppRoutes.tournament ||
    AppRoutes.trophyRoom ||
    AppRoutes.endMatch =>
      initialLocation,
    _ => AppRoutes.menu,
  };
}
