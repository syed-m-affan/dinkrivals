import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'save_service.dart';

abstract class HapticsService {
  Future<void> initialize();
  Future<void> light();
  Future<void> medium();
}

class FlutterHapticsService implements HapticsService {
  FlutterHapticsService({required bool Function() hapticsEnabled})
      : _hapticsEnabled = hapticsEnabled;

  final bool Function() _hapticsEnabled;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> light() async {
    if (!_hapticsEnabled()) {
      return;
    }
    await HapticFeedback.lightImpact();
  }

  @override
  Future<void> medium() async {
    if (!_hapticsEnabled()) {
      return;
    }
    await HapticFeedback.mediumImpact();
  }
}

class FakeHapticsService implements HapticsService {
  FakeHapticsService({bool Function()? hapticsEnabled})
      : _hapticsEnabled = hapticsEnabled ?? (() => true);

  final bool Function() _hapticsEnabled;
  bool initialized = false;
  int lightCalls = 0;
  int mediumCalls = 0;

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<void> light() async {
    if (_hapticsEnabled()) lightCalls++;
  }

  @override
  Future<void> medium() async {
    if (_hapticsEnabled()) mediumCalls++;
  }
}

final hapticsServiceProvider = Provider<HapticsService>((ref) {
  return FlutterHapticsService(
    hapticsEnabled: () => ref.read(saveDataProvider).hapticsEnabled,
  );
});
