import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dink_rivals/app/ad_provider.dart';
import 'package:dink_rivals/app/app_theme.dart';
import 'package:dink_rivals/app/audio_provider.dart';
import 'package:dink_rivals/app/game_provider.dart';
import 'package:dink_rivals/app/haptics_provider.dart';
import 'package:dink_rivals/game/dink_rivals_game.dart';
import 'package:dink_rivals/game/models/save_data.dart';
import 'package:dink_rivals/screens/end_match_screen.dart';
import 'package:dink_rivals/screens/main_menu_screen.dart';
import 'package:dink_rivals/screens/roster_screen.dart';
import 'package:dink_rivals/screens/settings_screen.dart';
import 'package:dink_rivals/services/audio_service.dart';
import 'package:dink_rivals/services/haptics_service.dart';
import 'package:dink_rivals/services/save_service.dart';

void main() {
  const surfaceSize = Size(412, 915);

  setUpAll(_loadGoldenFonts);

  testWidgets('phase 5g menu screenshot', (tester) async {
    await _setScreenshotSurface(tester, surfaceSize);
    await tester.pumpWidget(await _wrap(const MainMenuScreen()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/art/phase-5/phase-5g-menu.png'),
    );
  });

  testWidgets('phase 5g roster screenshot', (tester) async {
    await _setScreenshotSurface(tester, surfaceSize);
    await tester.pumpWidget(await _wrap(const RosterScreen()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/art/phase-5/phase-5g-roster.png'),
    );
  });

  testWidgets('phase 5g settings screenshot', (tester) async {
    await _setScreenshotSurface(tester, surfaceSize);
    await tester.pumpWidget(await _wrap(const SettingsScreen()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/art/phase-5/phase-5g-settings.png'),
    );
  });

  testWidgets('phase 5g end match screenshot', (tester) async {
    await _setScreenshotSurface(tester, surfaceSize);
    final game = DinkRivalsGame()
      ..matchState.playerScore = 7
      ..matchState.opponentScore = 4
      ..matchState.rallyCount = 12
      ..matchState.longestRally = 19;

    await tester.pumpWidget(await _wrap(const EndMatchScreen(), game: game));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/art/phase-5/phase-5g-endmatch.png'),
    );
  });
}

Future<void> _setScreenshotSurface(
  WidgetTester tester,
  Size surfaceSize,
) async {
  await tester.binding.setSurfaceSize(surfaceSize);
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });
}

Future<void> _loadGoldenFonts() async {
  await _loadFontFamily(
    family: 'monospace',
    candidates: const [
      r'C:\Windows\Fonts\consola.ttf',
      r'C:\Windows\Fonts\cour.ttf',
      '/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf',
    ],
  );

  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ??
      (Platform.isWindows ? r'C:\Users\saffa\flutter' : '');
  await _loadFontFamily(
    family: 'MaterialIcons',
    candidates: [
      if (flutterRoot.isNotEmpty)
        '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ],
  );
}

Future<void> _loadFontFamily({
  required String family,
  required List<String> candidates,
}) async {
  for (final path in candidates) {
    final file = File(path);
    if (!file.existsSync()) {
      continue;
    }
    final bytes = await file.readAsBytes();
    final loader = FontLoader(family)
      ..addFont(
        Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)),
      );
    await loader.load();
    return;
  }
}

Future<Widget> _wrap(Widget child, {DinkRivalsGame? game}) async {
  SharedPreferences.setMockInitialValues({});
  final saveService = SaveService(await SharedPreferences.getInstance());
  const saveData = SaveData();
  final resolvedGame = game ?? DinkRivalsGame();

  return ProviderScope(
    overrides: [
      dinkRivalsGameProvider.overrideWithValue(resolvedGame),
      adServiceProvider.overrideWithValue(FakeAdService()),
      adPlacementSystemProvider.overrideWithValue(AdPlacementSystem()),
      audioServiceProvider.overrideWithValue(FakeAudioService()),
      hapticsServiceProvider.overrideWithValue(FakeHapticsService()),
      saveServiceProvider.overrideWithValue(saveService),
      saveDataProvider.overrideWith(
        () => SaveDataNotifier(saveService, saveData),
      ),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: child,
    ),
  );
}
