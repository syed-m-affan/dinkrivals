import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dink_rivals/app/ad_provider.dart';
import 'package:dink_rivals/game/models/save_data.dart';
import 'package:dink_rivals/services/ad_service.dart';
import 'package:dink_rivals/services/save_service.dart';
import 'package:dink_rivals/widgets/ad_banner_slot.dart';

class _RemovedAdService extends FakeAdService {
  @override
  bool get adsRemoved => true;
}

Future<Widget> _wrap({
  required SaveData saveData,
  AdService? adService,
}) async {
  SharedPreferences.setMockInitialValues({});
  final service = SaveService(await SharedPreferences.getInstance());
  return ProviderScope(
    overrides: [
      saveServiceProvider.overrideWithValue(service),
      saveDataProvider.overrideWith(() => SaveDataNotifier(service, saveData)),
      if (adService != null) adServiceProvider.overrideWithValue(adService),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: AdBannerSlot(placement: 'menu'),
      ),
    ),
  );
}

void main() {
  testWidgets('banner placeholder is hidden before first completed match',
      (tester) async {
    await tester.pumpWidget(await _wrap(saveData: const SaveData()));

    expect(find.byKey(const Key('fake-banner-menu')), findsNothing);
  });

  testWidgets('fake banner stays hidden when RC placeholders are disabled',
      (tester) async {
    await tester.pumpWidget(
      await _wrap(
        saveData: const SaveData(matchesCompleted: 1),
        adService: FakeAdService(),
      ),
    );

    expect(find.byKey(const Key('fake-banner-menu')), findsNothing);
    expect(find.text('TEST BANNER'), findsNothing);
  });

  testWidgets('banner placeholder is hidden when ads are removed',
      (tester) async {
    await tester.pumpWidget(
      await _wrap(
        saveData: const SaveData(matchesCompleted: 1),
        adService: _RemovedAdService(),
      ),
    );

    expect(find.byKey(const Key('fake-banner-menu')), findsNothing);
  });
}
