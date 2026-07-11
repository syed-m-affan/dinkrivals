import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/app/audio_provider.dart';
import 'package:dink_rivals/services/audio_service.dart';

void main() {
  test('sound disabled short-circuits every play method', () async {
    final service = FakeAudioService(soundEnabled: () => false);

    await service.playHit();
    await service.playBounce();
    await service.playPoint();
    await service.playFault();
    await service.playMenuClick();

    expect(service.hitCalls, 0);
    expect(service.bounceCalls, 0);
    expect(service.pointCalls, 0);
    expect(service.faultCalls, 0);
    expect(service.menuClickCalls, 0);
  });

  test('sound enabled records exactly one call per play method', () async {
    final service = FakeAudioService(soundEnabled: () => true);

    await service.playHit();
    await service.playBounce();
    await service.playPoint();
    await service.playFault();
    await service.playMenuClick();

    expect(service.hitCalls, 1);
    expect(service.bounceCalls, 1);
    expect(service.pointCalls, 1);
    expect(service.faultCalls, 1);
    expect(service.menuClickCalls, 1);
  });

  test('initialize is idempotent', () async {
    final service = FakeAudioService();

    await service.initialize();
    await service.initialize();

    expect(service.initialized, isTrue);
    expect(service.initializeCalls, 1);
  });

  test('disposed fake ignores later initialize and play calls', () async {
    final service = FakeAudioService();

    service.dispose();
    await service.initialize();
    await service.playHit();
    await service.playBounce();
    await service.playPoint();
    await service.playFault();
    await service.playMenuClick();

    expect(service.disposed, isTrue);
    expect(service.disposeCalls, 1);
    expect(service.initialized, isFalse);
    expect(service.hitCalls, 0);
    expect(service.bounceCalls, 0);
    expect(service.pointCalls, 0);
    expect(service.faultCalls, 0);
    expect(service.menuClickCalls, 0);
  });

  test('provider can return an initialized fake', () async {
    final fake = FakeAudioService();
    await fake.initialize();
    final container = ProviderContainer(
      overrides: [audioServiceProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    expect(container.read(audioServiceProvider), same(fake));
    expect(fake.initialized, isTrue);
  });
}
