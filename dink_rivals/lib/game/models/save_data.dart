class SaveData {
  const SaveData({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.matchesCompleted = 0,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;
  final int matchesCompleted;

  SaveData copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    int? matchesCompleted,
  }) {
    return SaveData(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      matchesCompleted: matchesCompleted ?? this.matchesCompleted,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SaveData &&
        other.soundEnabled == soundEnabled &&
        other.hapticsEnabled == hapticsEnabled &&
        other.matchesCompleted == matchesCompleted;
  }

  @override
  int get hashCode =>
      Object.hash(soundEnabled, hapticsEnabled, matchesCompleted);
}
