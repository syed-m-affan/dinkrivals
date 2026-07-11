import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dink_rivals/game/models/save_data.dart';
import 'package:dink_rivals/screens/main_menu_screen.dart';
import 'package:dink_rivals/services/save_service.dart';

void main() {
  Future<Widget> app({required double textScale}) async {
    SharedPreferences.setMockInitialValues({});
    final service = SaveService(await SharedPreferences.getInstance());
    return ProviderScope(
      overrides: [
        saveServiceProvider.overrideWithValue(service),
        saveDataProvider.overrideWith(
          () => SaveDataNotifier(service, const SaveData()),
        ),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const MainMenuScreen(),
        ),
      ),
    );
  }

  for (final scenario in const [
    (size: Size(360, 800), textScale: 1.0),
    (size: Size(412, 915), textScale: 1.3),
  ]) {
    testWidgets(
      'arcade hub fits ${scenario.size.width}x${scenario.size.height} '
      'at ${scenario.textScale}x text',
      (tester) async {
        tester.view.physicalSize = scenario.size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(await app(textScale: scenario.textScale));
        await tester.pump();

        expect(find.byKey(const Key('menu-quick-match')), findsOneWidget);
        expect(find.byKey(const Key('menu-tournament')), findsOneWidget);
        expect(find.byKey(const Key('menu-roster')), findsOneWidget);
        expect(find.byKey(const Key('menu-courts')), findsOneWidget);
        expect(find.byKey(const Key('menu-trophy-room')), findsOneWidget);
        expect(find.byKey(const Key('menu-settings')), findsOneWidget);
        expect(find.byKey(const Key('menu-debug-rally')), findsNothing);
        expect(find.byKey(const Key('menu-phase-label')), findsNothing);

        final poster = tester.getRect(
          find.byKey(const Key('menu-match-poster')),
        );
        final quick = tester.getRect(
          find.byKey(const Key('menu-quick-match')),
        );
        final cup = tester.getRect(find.byKey(const Key('menu-tournament')));
        final roster = tester.getRect(find.byKey(const Key('menu-roster')));
        expect(quick.top - poster.bottom, lessThanOrEqualTo(20));
        expect(cup.top - quick.bottom, lessThanOrEqualTo(12));
        expect(roster.top - cup.bottom, lessThanOrEqualTo(16));
        expect(quick.top, lessThan(scenario.size.height * 0.70));
        expect(quick.height, greaterThanOrEqualTo(48));
        expect(roster.height, greaterThanOrEqualTo(48));
        expect(tester.takeException(), isNull);
      },
    );
  }
}
