import 'character_unlock.dart';
import 'court_unlock.dart';
import 'gameplay_control_mode.dart';

class SaveData {
  const SaveData({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.gameplayControlMode = GameplayControlMode.classicRacketStick,
    this.matchesCompleted = 0,
    this.classicCupWins = 0,
    this.stars = 0,
    this.tutorialSeen = false,
    this.dinkStreakPaddleUnlocked = false,
    this.selectedCourtId = CourtUnlockIds.defaultCourt,
    this.unlockedCharacterIds = CharacterUnlockIds.defaultUnlocked,
    this.selectedCharacterId = CharacterUnlockIds.defaultSelected,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;
  final GameplayControlMode gameplayControlMode;
  final int matchesCompleted;
  final int classicCupWins;
  final int stars;
  final bool tutorialSeen;
  final bool dinkStreakPaddleUnlocked;
  final String selectedCourtId;
  final List<String> unlockedCharacterIds;
  final String selectedCharacterId;

  bool get classicCupTrophyUnlocked => classicCupWins > 0;
  bool get parkCourtUnlocked => true;
  bool isCharacterUnlocked(String id) =>
      normalizedCharacterUnlocks(unlockedCharacterIds).contains(id);
  String get activeCharacterId => normalizedSelectedCharacterId(
        selectedCharacterId,
        unlockedCharacterIds,
      );

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
    bool? dinkStreakPaddleUnlocked,
    String? selectedCourtId,
    List<String>? unlockedCharacterIds,
    String? selectedCharacterId,
  }) {
    return SaveData(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      gameplayControlMode: gameplayControlMode ?? this.gameplayControlMode,
      matchesCompleted: matchesCompleted ?? this.matchesCompleted,
      classicCupWins: classicCupWins ?? this.classicCupWins,
      stars: stars ?? this.stars,
      tutorialSeen: tutorialSeen ?? this.tutorialSeen,
      dinkStreakPaddleUnlocked:
          dinkStreakPaddleUnlocked ?? this.dinkStreakPaddleUnlocked,
      selectedCourtId: selectedCourtId ?? this.selectedCourtId,
      unlockedCharacterIds: unlockedCharacterIds ?? this.unlockedCharacterIds,
      selectedCharacterId: selectedCharacterId ?? this.selectedCharacterId,
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
        other.dinkStreakPaddleUnlocked == dinkStreakPaddleUnlocked &&
        other.selectedCourtId == selectedCourtId &&
        _stringListEquals(other.unlockedCharacterIds, unlockedCharacterIds) &&
        other.selectedCharacterId == selectedCharacterId;
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
        dinkStreakPaddleUnlocked,
        selectedCourtId,
        Object.hashAll(unlockedCharacterIds),
        selectedCharacterId,
      );
}

bool _stringListEquals(List<String> a, List<String> b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i += 1) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}
