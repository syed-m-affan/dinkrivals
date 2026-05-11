enum GameplayControlMode {
  assistedAimGesture,
  classicRacketStick,
}

GameplayControlMode gameplayControlModeFromStorageValue(String? value) {
  return switch (value) {
    'classic_racket_stick' => GameplayControlMode.classicRacketStick,
    _ => GameplayControlMode.assistedAimGesture,
  };
}

extension GameplayControlModePersistence on GameplayControlMode {
  String get storageValue => switch (this) {
        GameplayControlMode.assistedAimGesture => 'assisted_aim_gesture',
        GameplayControlMode.classicRacketStick => 'classic_racket_stick',
      };

  String get label => switch (this) {
        GameplayControlMode.assistedAimGesture => 'Assisted Controls',
        GameplayControlMode.classicRacketStick => 'Classic Racket Stick',
      };

  String get settingsSubtitle => switch (this) {
        GameplayControlMode.assistedAimGesture =>
          'Aim with your thumb; tap, flick, or hold to choose the shot.',
        GameplayControlMode.classicRacketStick =>
          'Manually sweep the racket stick for timing and direction.',
      };
}
