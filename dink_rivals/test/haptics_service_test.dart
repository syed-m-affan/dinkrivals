import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/services/haptics_service.dart';

void main() {
  test('haptics disabled short-circuits light and medium', () async {
    final service = FakeHapticsService(hapticsEnabled: () => false);

    await service.light();
    await service.medium();

    expect(service.lightCalls, 0);
    expect(service.mediumCalls, 0);
  });

  test('haptics enabled records one impact per call', () async {
    final service = FakeHapticsService(hapticsEnabled: () => true);

    await service.light();
    await service.medium();

    expect(service.lightCalls, 1);
    expect(service.mediumCalls, 1);
  });

  test('initialize is available for provider bootstrap', () async {
    final service = FakeHapticsService();

    await service.initialize();

    expect(service.initialized, isTrue);
  });

  test('disposed fake ignores later initialize and impact calls', () async {
    final service = FakeHapticsService();

    service.dispose();
    await service.initialize();
    await service.light();
    await service.medium();

    expect(service.disposed, isTrue);
    expect(service.disposeCalls, 1);
    expect(service.initialized, isFalse);
    expect(service.lightCalls, 0);
    expect(service.mediumCalls, 0);
  });
}
