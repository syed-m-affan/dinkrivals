import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/ad_provider.dart';
import 'app/app.dart';
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
  final adService = FakeAdService();
  await adService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        adServiceProvider.overrideWithValue(adService),
        saveServiceProvider.overrideWithValue(saveService),
        saveDataProvider.overrideWith(
          () => SaveDataNotifier(saveService, initialSaveData),
        ),
      ],
      child: const DinkRivalsApp(),
    ),
  );
}
