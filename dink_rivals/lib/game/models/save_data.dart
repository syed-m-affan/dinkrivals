import 'gameplay_control_mode.dart';

class SaveData {
  const SaveData({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.gameplayControlMode = GameplayControlMode.classicRacketStick,
    this.matchesCompleted = 0,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;
  final GameplayControlMode gameplayControlMode;
  final int matchesCompleted;

  SaveData copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    GameplayControlMode? gameplayControlMode,
    int? matchesCompleted,
  }) {
    return SaveData(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      gameplayControlMode: gameplayControlMode ?? this.gameplayControlMode,
      matchesCompleted: matchesCompleted ?? this.matchesCompleted,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SaveData &&
        other.soundEnabled == soundEnabled &&
        other.hapticsEnabled == hapticsEnabled &&
        other.gameplayControlMode == gameplayControlMode &&
        other.matchesCompleted == matchesCompleted;
  }

  @override
  int get hashCode => Object.hash(
        soundEnabled,
        hapticsEnabled,
        gameplayControlMode,
        matchesCompleted,
      );
}
