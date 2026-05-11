import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'save_service.dart';

abstract class AudioService {
  Future<void> initialize();
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

  final bool Function() _soundEnabled;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    await FlameAudio.audioCache.loadAll([
      _hit,
      _bounce,
      _point,
      _fault,
      _menuClick,
    ]);
    _initialized = true;
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
    if (!_soundEnabled()) {
      return;
    }
    await FlameAudio.play(file);
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

  @override
  Future<void> initialize() async {
    if (initialized) {
      return;
    }
    initialized = true;
    initializeCalls++;
  }

  @override
  Future<void> playHit() async {
    if (_soundEnabled()) hitCalls++;
  }

  @override
  Future<void> playBounce() async {
    if (_soundEnabled()) bounceCalls++;
  }

  @override
  Future<void> playPoint() async {
    if (_soundEnabled()) pointCalls++;
  }

  @override
  Future<void> playFault() async {
    if (_soundEnabled()) faultCalls++;
  }

  @override
  Future<void> playMenuClick() async {
    if (_soundEnabled()) menuClickCalls++;
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  return FlameAudioService(
    soundEnabled: () => ref.read(saveDataProvider).soundEnabled,
  );
});
