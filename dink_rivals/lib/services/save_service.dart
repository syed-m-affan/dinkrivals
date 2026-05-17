import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../game/models/gameplay_control_mode.dart';
import '../game/models/save_data.dart';

class SaveService {
  SaveService(this._prefs);

  static const _versionKey = 'save_version';
  static const _soundKey = 'sound_enabled';
  static const _hapticsKey = 'haptics_enabled';
  static const _controlModeKey = 'gameplay_control_mode';
  static const _matchesKey = 'matches_completed';
  static const _classicCupWinsKey = 'classic_cup_wins';
  static const _currentVersion = 1;

  final SharedPreferences _prefs;

  Future<SaveData> load() async {
    return SaveData(
      soundEnabled: _prefs.getBool(_soundKey) ?? true,
      hapticsEnabled: _prefs.getBool(_hapticsKey) ?? true,
      gameplayControlMode: gameplayControlModeFromStorageValue(
          _prefs.getString(_controlModeKey)),
      matchesCompleted: _prefs.getInt(_matchesKey) ?? 0,
      classicCupWins: _prefs.getInt(_classicCupWinsKey) ?? 0,
    );
  }

  Future<void> save(SaveData data) async {
    await _prefs.setInt(_versionKey, _currentVersion);
    await _prefs.setBool(_soundKey, data.soundEnabled);
    await _prefs.setBool(_hapticsKey, data.hapticsEnabled);
    await _prefs.setString(
      _controlModeKey,
      data.gameplayControlMode.storageValue,
    );
    await _prefs.setInt(_matchesKey, data.matchesCompleted);
    await _prefs.setInt(_classicCupWinsKey, data.classicCupWins);
  }
}

final saveServiceProvider = Provider<SaveService>((ref) {
  throw UnimplementedError(
      'saveServiceProvider must be overridden in main.dart');
});

class SaveDataNotifier extends Notifier<SaveData> {
  SaveDataNotifier(this._service, this._initial);

  final SaveService _service;
  final SaveData _initial;

  @override
  SaveData build() => _initial;

  Future<void> setSoundEnabled(bool value) async {
    state = state.copyWith(soundEnabled: value);
    await _service.save(state);
  }

  Future<void> setHapticsEnabled(bool value) async {
    state = state.copyWith(hapticsEnabled: value);
    await _service.save(state);
  }

  Future<void> setGameplayControlMode(GameplayControlMode value) async {
    state = state.copyWith(gameplayControlMode: value);
    await _service.save(state);
  }

  Future<void> recordMatchCompleted() async {
    state = state.copyWith(matchesCompleted: state.matchesCompleted + 1);
    await _service.save(state);
  }

  Future<void> recordClassicCupWin() async {
    state = state.copyWith(classicCupWins: state.classicCupWins + 1);
    await _service.save(state);
  }
}

final saveDataProvider = NotifierProvider<SaveDataNotifier, SaveData>(() {
  throw UnimplementedError('saveDataProvider must be overridden in main.dart');
});
