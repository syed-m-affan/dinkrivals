import 'gameplay_control_mode.dart';
import 'court_unlock.dart';

class SaveData {
  const SaveData({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.gameplayControlMode = GameplayControlMode.classicRacketStick,
    this.matchesCompleted = 0,
    this.classicCupWins = 0,
    this.stars = 0,
    this.tutorialSeen = false,
    this.selectedCourtId = CourtUnlockIds.defaultCourt,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;
  final GameplayControlMode gameplayControlMode;
  final int matchesCompleted;
  final int classicCupWins;
  final int stars;
  final bool tutorialSeen;
  final String selectedCourtId;

  bool get classicCupTrophyUnlocked => classicCupWins > 0;
  bool get parkCourtUnlocked => true;
  String get activeCourtId {
    final normalized = normalizedCourtId(selectedCourtId);
    return normalized;
  }

  SaveData copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    GameplayControlMode? gameplayControlMode,
    int? matchesCompleted,
    int? classicCupWins,
    int? stars,
    bool? tutorialSeen,
    String? selectedCourtId,
  }) {
    return SaveData(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      gameplayControlMode: gameplayControlMode ?? this.gameplayControlMode,
      matchesCompleted: matchesCompleted ?? this.matchesCompleted,
      classicCupWins: classicCupWins ?? this.classicCupWins,
      stars: stars ?? this.stars,
      tutorialSeen: tutorialSeen ?? this.tutorialSeen,
      selectedCourtId: selectedCourtId ?? this.selectedCourtId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SaveData &&
        other.soundEnabled == soundEnabled &&
        other.hapticsEnabled == hapticsEnabled &&
        other.gameplayControlMode == gameplayControlMode &&
        other.matchesCompleted == matchesCompleted &&
        other.classicCupWins == classicCupWins &&
        other.stars == stars &&
        other.tutorialSeen == tutorialSeen &&
        other.selectedCourtId == selectedCourtId;
  }

  @override
  int get hashCode => Object.hash(
        soundEnabled,
        hapticsEnabled,
        gameplayControlMode,
        matchesCompleted,
        classicCupWins,
        stars,
        tutorialSeen,
        selectedCourtId,
      );
}
