enum GameplayControlMode {
  classicRacketStick,
}

GameplayControlMode gameplayControlModeFromStorageValue(String? value) {
  return GameplayControlMode.classicRacketStick;
}

extension GameplayControlModePersistence on GameplayControlMode {
  String get storageValue => switch (this) {
        GameplayControlMode.classicRacketStick => 'classic_racket_stick',
      };

  String get label => switch (this) {
        GameplayControlMode.classicRacketStick => 'Manual Controls',
      };

  String get settingsSubtitle => switch (this) {
        GameplayControlMode.classicRacketStick =>
          'Left stick moves, right stick aims, swipes choose attack shots.',
      };
}
