import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'save_service.dart';

abstract class HapticsService {
  Future<void> initialize();
  void dispose();
  Future<void> light();
  Future<void> medium();
}

class FlutterHapticsService implements HapticsService {
  FlutterHapticsService({required bool Function() hapticsEnabled})
      : _hapticsEnabled = hapticsEnabled;

  final bool Function() _hapticsEnabled;
  bool _disposed = false;

  @override
  Future<void> initialize() async {}

  @override
  void dispose() {
    _disposed = true;
  }

  @override
  Future<void> light() async {
    if (_disposed || !_hapticsEnabled()) {
      return;
    }
    await HapticFeedback.lightImpact();
  }

  @override
  Future<void> medium() async {
    if (_disposed || !_hapticsEnabled()) {
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
  bool disposed = false;
  int disposeCalls = 0;
  int lightCalls = 0;
  int mediumCalls = 0;

  @override
  Future<void> initialize() async {
    if (disposed) {
      return;
    }
    initialized = true;
  }

  @override
  void dispose() {
    disposed = true;
    disposeCalls++;
  }

  @override
  Future<void> light() async {
    if (!disposed && _hapticsEnabled()) lightCalls++;
  }

  @override
  Future<void> medium() async {
    if (!disposed && _hapticsEnabled()) mediumCalls++;
  }
}

final hapticsServiceProvider = Provider<HapticsService>((ref) {
  final service = FlutterHapticsService(
    hapticsEnabled: () => ref.read(saveDataProvider).hapticsEnabled,
  );
  ref.onDispose(service.dispose);
  return service;
});
