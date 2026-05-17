import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/audio_provider.dart';
import '../app/game_provider.dart';
import '../app/rival_challenge_provider.dart';
import '../app/router.dart';
import '../game/config/character_visuals.dart';
import '../game/config/tournament_definitions.dart';
import '../game/config/visual_palette.dart';
import '../services/save_service.dart';
import '../widgets/arcade_button.dart';
import '../widgets/arcade_panel.dart';
import '../widgets/park_backdrop.dart';

class _CharacterDef {
  const _CharacterDef({
    required this.name,
    required this.role,
    required this.strength,
    required this.weakness,
  });

  final String name;
  final String role;
  final String strength;
  final String weakness;
}

const _mvpRoster = <_CharacterDef>[
  _CharacterDef(
    name: 'Rookie',
    role: 'Default balanced player',
    strength: 'Easy control',
    weakness: 'No specialty',
  ),
  _CharacterDef(
    name: 'Rally Queen',
    role: 'Dink / control specialist',
    strength: 'Soft game',
    weakness: 'Lower power',
  ),
  _CharacterDef(
    name: 'Veteran',
    role: 'Defensive placement',
    strength: 'Consistency',
    weakness: 'Slower speed',
  ),
  _CharacterDef(
    name: 'Showman',
    role: 'Aggressive flashy player',
    strength: 'Power / specials',
    weakness: 'Less consistent',
  ),
];

class RosterScreen extends ConsumerWidget {
  const RosterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final save = ref.watch(saveDataProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ROSTER'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(audioServiceProvider).playMenuClick();
            context.go(AppRoutes.menu);
          },
        ),
      ),
      body: ParkBackdrop(
        overlayOpacity: 0.78,
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _mvpRoster.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final char = _mvpRoster[index];
              final visual = CharacterVisuals.byDisplayName(char.name);
              final unlocked = save.isCharacterUnlocked(visual.id);
              final challengeRival = _challengeRivalFor(visual.id);
              return ArcadePanel(
                backgroundColor: VisualPalette.uiSurface.withValues(
                  alpha: 0.88,
                ),
                borderColor: unlocked
                    ? VisualPalette.courtLineWhite.withValues(alpha: 0.52)
                    : VisualPalette.textMuted.withValues(alpha: 0.58),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: unlocked ? 1 : 0.42,
                          child: Image.asset(
                            visual.portraitAsset,
                            key: Key('roster-portrait-${char.name}'),
                            width: 72,
                            height: 72,
                            filterQuality: FilterQuality.none,
                          ),
                        ),
                        if (!unlocked)
                          const Icon(
                            Icons.lock,
                            key: Key('roster-locked-icon'),
                            color: VisualPalette.courtLineWhite,
                            size: 30,
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            char.name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: VisualPalette.uiAccent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            unlocked ? 'UNLOCKED' : 'LOCKED',
                            key: Key('roster-unlock-${visual.id}'),
                            style: TextStyle(
                              color: unlocked
                                  ? VisualPalette.feedbackDink
                                  : VisualPalette.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            char.role,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: VisualPalette.courtLineWhite,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Strength: ${char.strength}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Weakness: ${char.weakness}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (!unlocked && challengeRival != null) ...[
                            const SizedBox(height: 10),
                            ArcadeButton(
                              key: Key('roster-challenge-${visual.id}'),
                              label: 'CHALLENGE',
                              icon: Icons.sports_tennis,
                              compact: true,
                              onPressed: () {
                                ref.read(audioServiceProvider).playMenuClick();
                                ref
                                    .read(rivalChallengeProvider.notifier)
                                    .start(challengeRival.id);
                                final game = ref.read(dinkRivalsGameProvider);
                                game.setOpponentAiProfile(
                                  challengeRival.aiProfile,
                                );
                                game.resetMatch();
                                context.go(AppRoutes.game);
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

TournamentRival? _challengeRivalFor(String characterId) {
  if (characterId == TournamentDefinitions.veteran.id) {
    return TournamentDefinitions.veteran;
  }
  if (characterId == TournamentDefinitions.showman.id) {
    return TournamentDefinitions.showman;
  }
  return null;
}
