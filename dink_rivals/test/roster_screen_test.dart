import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:dink_rivals/app/audio_provider.dart';
import 'package:dink_rivals/screens/roster_screen.dart';
import 'package:dink_rivals/services/audio_service.dart';

void main() {
  testWidgets('roster shows four portrait images', (tester) async {
    final router = GoRouter(
      initialLocation: '/roster',
      routes: [
        GoRoute(
          path: '/roster',
          builder: (context, state) => const RosterScreen(),
        ),
        GoRoute(path: '/', builder: (context, state) => const SizedBox()),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [audioServiceProvider.overrideWithValue(FakeAudioService())],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();

    expect(find.byType(Image), findsNWidgets(4));
    expect(find.byKey(const Key('roster-portrait-Rookie')), findsOneWidget);
    expect(
      find.byKey(const Key('roster-portrait-Rally Queen')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('roster-portrait-Veteran')), findsOneWidget);
    expect(find.byKey(const Key('roster-portrait-Showman')), findsOneWidget);
  });
}
