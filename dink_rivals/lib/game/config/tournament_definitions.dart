import '../models/opponent_ai_profile.dart';
import 'character_visuals.dart';
import 'tuning_constants.dart';

class TournamentRival {
  const TournamentRival({
    required this.id,
    required this.displayName,
    required this.seedLabel,
    required this.visual,
    required this.aiProfile,
  });

  final String id;
  final String displayName;
  final String seedLabel;
  final CharacterVisualDefinition visual;
  final OpponentAiProfile aiProfile;
}

class TournamentDefinitions {
  static const classicCupId = 'classic_cup';
  static const classicCupName = 'Classic Cup';
  static const classicCupTrophyName = 'Classic Cup Trophy';

  static const rookie = TournamentRival(
    id: 'rookie',
    displayName: 'Rookie',
    seedLabel: 'Seed 4',
    visual: CharacterVisuals.rookie,
    aiProfile: OpponentAiProfile(
      id: 'rookie',
      displayName: 'Rookie',
      maxSpeed: Tuning.opponentMaxSpeed * 0.94,
      whiffChance: Tuning.opponentWhiffChance + 0.08,
      dinkProbability: Tuning.opponentDinkProbability,
      lobProbability: Tuning.opponentLobProbability * 0.70,
      smashProbability: Tuning.opponentSmashProbability * 0.55,
    ),
  );

  static const rallyQueen = TournamentRival(
    id: 'rally_queen',
    displayName: 'Rally Queen',
    seedLabel: 'Seed 4',
    visual: CharacterVisuals.rallyQueen,
    aiProfile: OpponentAiProfile(
      id: 'rally_queen',
      displayName: 'Rally Queen',
      maxSpeed: Tuning.opponentMaxSpeed * 1.02,
      whiffChance: Tuning.opponentWhiffChance * 0.68,
      dinkProbability: Tuning.opponentDinkProbability * 1.28,
      lobProbability: Tuning.opponentLobProbability * 0.78,
      smashProbability: Tuning.opponentSmashProbability * 0.62,
    ),
  );

  static const veteran = TournamentRival(
    id: 'veteran',
    displayName: 'Veteran',
    seedLabel: 'Seed 3',
    visual: CharacterVisuals.veteran,
    aiProfile: OpponentAiProfile(
      id: 'veteran',
      displayName: 'Veteran',
      maxSpeed: Tuning.opponentMaxSpeed * 1.04,
      whiffChance: Tuning.opponentWhiffChance * 0.72,
      dinkProbability: Tuning.opponentDinkProbability * 0.92,
      lobProbability: Tuning.opponentLobProbability * 1.15,
      smashProbability: Tuning.opponentSmashProbability * 0.90,
    ),
  );

  static const showman = TournamentRival(
    id: 'showman',
    displayName: 'Showman',
    seedLabel: 'Seed 2',
    visual: CharacterVisuals.showman,
    aiProfile: OpponentAiProfile(
      id: 'showman',
      displayName: 'Showman',
      maxSpeed: Tuning.opponentMaxSpeed * 1.12,
      whiffChance: Tuning.opponentWhiffChance * 0.58,
      dinkProbability: Tuning.opponentDinkProbability * 0.76,
      lobProbability: Tuning.opponentLobProbability * 1.24,
      smashProbability: Tuning.opponentSmashProbability * 1.35,
    ),
  );

  static const rivals = [rookie, rallyQueen, veteran, showman];
  static const semifinalRival = rallyQueen;
  static const otherSemifinalRival = veteran;
  static const finalRival = showman;

  static TournamentRival byId(String id) {
    return rivals.firstWhere(
      (rival) => rival.id == id,
      orElse: () => throw ArgumentError.value(
        id,
        'id',
        'No tournament rival exists with this id.',
      ),
    );
  }
}
