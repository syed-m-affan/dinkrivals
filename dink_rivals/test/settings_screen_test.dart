import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dink_rivals/game/models/save_data.dart';
import 'package:dink_rivals/screens/settings_screen.dart';
import 'package:dink_rivals/services/save_service.dart';

Widget _wrap(Widget child, SaveService service, SaveData initial) {
  return ProviderScope(
    overrides: [
      saveServiceProvider.overrideWithValue(service),
      saveDataProvider.overrideWith(() => SaveDataNotifier(service, initial)),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('toggling Sound flips the switch and persists', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);

    await tester
        .pumpWidget(_wrap(const SettingsScreen(), service, const SaveData()));

    final soundFinder = find.byKey(const Key('settings-sound-toggle'));
    expect(soundFinder, findsOneWidget);
    expect(tester.widget<SwitchListTile>(soundFinder).value, isTrue);

    await tester.tap(soundFinder);
    await tester.pumpAndSettle();

    expect(tester.widget<SwitchListTile>(soundFinder).value, isFalse);

    final reloaded = await SaveService(prefs).load();
    expect(reloaded.soundEnabled, isFalse);
  });

  testWidgets('toggling Haptics flips the switch and persists', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);

    await tester
        .pumpWidget(_wrap(const SettingsScreen(), service, const SaveData()));

    final hapticsFinder = find.byKey(const Key('settings-haptics-toggle'));
    expect(tester.widget<SwitchListTile>(hapticsFinder).value, isTrue);

    await tester.tap(hapticsFinder);
    await tester.pumpAndSettle();

    expect(tester.widget<SwitchListTile>(hapticsFinder).value, isFalse);

    final reloaded = await SaveService(prefs).load();
    expect(reloaded.hapticsEnabled, isFalse);
  });
}
