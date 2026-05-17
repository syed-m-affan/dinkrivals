import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/ad_provider.dart';
import 'app/app.dart';
import 'app/app_config.dart';
import 'services/admob_ad_service.dart';
import 'services/audio_service.dart';
import 'services/haptics_service.dart';
import 'services/save_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final prefs = await SharedPreferences.getInstance();
  final saveService = SaveService(prefs);
  final initialSaveData = await saveService.load();
  final adService = AppConfig.useAdMob ? AdMobAdService() : FakeAdService();
  await adService.initialize();
  final audioService = FlameAudioService(
    soundEnabled: () => initialSaveData.soundEnabled,
  );
  await audioService.initialize();
  final hapticsService = FlutterHapticsService(
    hapticsEnabled: () => initialSaveData.hapticsEnabled,
  );
  await hapticsService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        adServiceProvider.overrideWithValue(adService),
        audioServiceProvider.overrideWith(
          (ref) => FlameAudioService(
            soundEnabled: () => ref.read(saveDataProvider).soundEnabled,
          ),
        ),
        hapticsServiceProvider.overrideWith(
          (ref) => FlutterHapticsService(
            hapticsEnabled: () => ref.read(saveDataProvider).hapticsEnabled,
          ),
        ),
        saveServiceProvider.overrideWithValue(saveService),
        saveDataProvider.overrideWith(
          () => SaveDataNotifier(saveService, initialSaveData),
        ),
      ],
      child: const DinkRivalsApp(),
    ),
  );
}
