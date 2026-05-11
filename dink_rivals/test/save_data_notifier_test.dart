import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dink_rivals/game/models/save_data.dart';
import 'package:dink_rivals/services/save_service.dart';

ProviderContainer _container(SaveService service, SaveData initial) {
  return ProviderContainer(
    overrides: [
      saveServiceProvider.overrideWithValue(service),
      saveDataProvider.overrideWith(() => SaveDataNotifier(service, initial)),
    ],
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('setSoundEnabled updates state and persists', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);
    final container = _container(service, const SaveData());
    addTearDown(container.dispose);

    await container.read(saveDataProvider.notifier).setSoundEnabled(false);

    expect(container.read(saveDataProvider).soundEnabled, isFalse);
    final reloaded = await SaveService(prefs).load();
    expect(reloaded.soundEnabled, isFalse);
  });

  test('setHapticsEnabled updates state and persists', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);
    final container = _container(service, const SaveData());
    addTearDown(container.dispose);

    await container.read(saveDataProvider.notifier).setHapticsEnabled(false);

    expect(container.read(saveDataProvider).hapticsEnabled, isFalse);
    final reloaded = await SaveService(prefs).load();
    expect(reloaded.hapticsEnabled, isFalse);
  });

  test('recordMatchCompleted increments by exactly one', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);
    final container =
        _container(service, const SaveData(matchesCompleted: 2));
    addTearDown(container.dispose);

    await container.read(saveDataProvider.notifier).recordMatchCompleted();
    await container.read(saveDataProvider.notifier).recordMatchCompleted();

    expect(container.read(saveDataProvider).matchesCompleted, 4);
    final reloaded = await SaveService(prefs).load();
    expect(reloaded.matchesCompleted, 4);
  });
}
