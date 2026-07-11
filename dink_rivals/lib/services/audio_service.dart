import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'save_service.dart';

abstract class AudioService {
  Future<void> initialize();
  void dispose();
  Future<void> playHit();
  Future<void> playBounce();
  Future<void> playPoint();
  Future<void> playFault();
  Future<void> playMenuClick();
}

class FlameAudioService implements AudioService {
  FlameAudioService({required bool Function() soundEnabled})
      : _soundEnabled = soundEnabled;

  static const _hit = 'sfx/hit.wav';
  static const _bounce = 'sfx/bounce.wav';
  static const _point = 'sfx/point.wav';
  static const _fault = 'sfx/fault.wav';
  static const _menuClick = 'sfx/menu_click.wav';
  static const _files = [_hit, _bounce, _point, _fault, _menuClick];
  static bool _cacheLoaded = false;
  static Future<void>? _cacheLoading;

  final bool Function() _soundEnabled;
  bool _initialized = false;
  bool _disposed = false;

  static Future<void> warmCache() => _ensureCacheLoaded();

  @override
  Future<void> initialize() async {
    if (_initialized || _disposed) {
      return;
    }
    await _ensureCacheLoaded();
    if (!_disposed) {
      _initialized = true;
    }
  }

  static Future<void> _ensureCacheLoaded() async {
    if (_cacheLoaded) {
      return;
    }
    final existingLoad = _cacheLoading;
    if (existingLoad != null) {
      await existingLoad;
      return;
    }
    final load = FlameAudio.audioCache.loadAll(_files);
    _cacheLoading = load;
    try {
      await load;
      _cacheLoaded = true;
    } finally {
      _cacheLoading = null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
  }

  @override
  Future<void> playHit() => _play(_hit);

  @override
  Future<void> playBounce() => _play(_bounce);

  @override
  Future<void> playPoint() => _play(_point);

  @override
  Future<void> playFault() => _play(_fault);

  @override
  Future<void> playMenuClick() => _play(_menuClick);

  Future<void> _play(String file) async {
    if (_disposed || !_soundEnabled()) {
      return;
    }
    await initialize();
    if (_disposed) {
      return;
    }
    try {
      await FlameAudio.play(file);
    } catch (error, stackTrace) {
      debugPrint('Audio playback failed for $file: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}

class FakeAudioService implements AudioService {
  FakeAudioService({bool Function()? soundEnabled})
      : _soundEnabled = soundEnabled ?? (() => true);

  final bool Function() _soundEnabled;
  bool initialized = false;
  int initializeCalls = 0;
  int hitCalls = 0;
  int bounceCalls = 0;
  int pointCalls = 0;
  int faultCalls = 0;
  int menuClickCalls = 0;
  int disposeCalls = 0;
  bool disposed = false;

  @override
  Future<void> initialize() async {
    if (initialized || disposed) {
      return;
    }
    initialized = true;
    initializeCalls++;
  }

  @override
  void dispose() {
    disposed = true;
    disposeCalls++;
  }

  @override
  Future<void> playHit() async {
    if (!disposed && _soundEnabled()) hitCalls++;
  }

  @override
  Future<void> playBounce() async {
    if (!disposed && _soundEnabled()) bounceCalls++;
  }

  @override
  Future<void> playPoint() async {
    if (!disposed && _soundEnabled()) pointCalls++;
  }

  @override
  Future<void> playFault() async {
    if (!disposed && _soundEnabled()) faultCalls++;
  }

  @override
  Future<void> playMenuClick() async {
    if (!disposed && _soundEnabled()) menuClickCalls++;
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = FlameAudioService(
    soundEnabled: () => ref.read(saveDataProvider).soundEnabled,
  );
  ref.onDispose(service.dispose);
  return service;
});
