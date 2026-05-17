import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/audio_provider.dart';
import '../app/router.dart';
import '../game/config/tournament_definitions.dart';
import '../game/config/visual_palette.dart';
import '../game/models/paddle_skin.dart';
import '../services/save_service.dart';
import '../widgets/ad_banner_slot.dart';
import '../widgets/arcade_panel.dart';
import '../widgets/park_backdrop.dart';

class TrophyRoomScreen extends ConsumerWidget {
  const TrophyRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final save = ref.watch(saveDataProvider);
    final saveNotifier = ref.read(saveDataProvider.notifier);
    final dinkStreakAccentEquipped =
        save.activePaddleSkinId == PaddleSkinIds.dinkStreak;
    return Scaffold(
      appBar: AppBar(
        title: const Text('TROPHY ROOM'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(audioServiceProvider).playMenuClick();
            context.go(AppRoutes.menu);
          },
        ),
      ),
      body: ParkBackdrop(
        overlayOpacity: 0.80,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    ArcadePanel(
                      backgroundColor:
                          VisualPalette.uiSurface.withValues(alpha: 0.88),
                      borderColor: VisualPalette.uiAccent,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: VisualPalette.uiAccent,
                            size: 34,
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'STARS',
                              style: TextStyle(
                                color: VisualPalette.courtLineWhite,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '${save.stars}',
                            key: const Key('trophy-room-stars'),
                            style: const TextStyle(
                              color: VisualPalette.uiAccent,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _UnlockRow(
                      keyName: 'classic-cup-trophy',
                      icon: Icons.emoji_events,
                      title: TournamentDefinitions.classicCupTrophyName,
                      detail: save.classicCupTrophyUnlocked
                          ? 'Classic Cup wins: ${save.classicCupWins}'
                          : 'Win Classic Cup',
                      unlocked: save.classicCupTrophyUnlocked,
                    ),
                    const SizedBox(height: 12),
                    _UnlockRow(
                      keyName: 'park-court',
                      icon: Icons.park,
                      title: 'Classic Park Court',
                      detail: 'Playable court',
                      unlocked: save.parkCourtUnlocked,
                    ),
                    const SizedBox(height: 12),
                    _UnlockRow(
                      keyName: 'dink-streak-paddle',
                      icon: Icons.sports_tennis,
                      title: PaddleSkins.dinkStreak.displayName,
                      detail: save.dinkStreakPaddleUnlocked
                          ? PaddleSkins.dinkStreak.detail
                          : 'Land five dinks in one match',
                      unlocked: save.dinkStreakPaddleUnlocked,
                      actionLabel: save.dinkStreakPaddleUnlocked
                          ? (dinkStreakAccentEquipped ? 'UNEQUIP' : 'EQUIP')
                          : null,
                      onAction: save.dinkStreakPaddleUnlocked
                          ? () {
                              ref.read(audioServiceProvider).playMenuClick();
                              saveNotifier.selectPaddleSkin(
                                dinkStreakAccentEquipped
                                    ? PaddleSkinIds.classic
                                    : PaddleSkinIds.dinkStreak,
                              );
                            }
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _UnlockRow(
                      keyName: 'tutorial',
                      icon: Icons.school,
                      title: 'Quick Start',
                      detail: save.tutorialSeen ? 'Seen' : 'Pending',
                      unlocked: save.tutorialSeen,
                    ),
                  ],
                ),
              ),
              const AdBannerSlot(placement: 'trophy-room'),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnlockRow extends StatelessWidget {
  const _UnlockRow({
    required this.keyName,
    required this.icon,
    required this.title,
    required this.detail,
    required this.unlocked,
    this.actionLabel,
    this.onAction,
  });

  final String keyName;
  final IconData icon;
  final String title;
  final String detail;
  final bool unlocked;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final color =
        unlocked ? VisualPalette.feedbackDink : VisualPalette.textMuted;
    return ArcadePanel(
      backgroundColor: VisualPalette.uiSurface.withValues(alpha: 0.86),
      borderColor: color.withValues(alpha: unlocked ? 0.92 : 0.46),
      child: Row(
        children: [
          Icon(
            unlocked ? icon : Icons.lock,
            key: Key('trophy-room-$keyName-icon'),
            color: color,
            size: 32,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  key: Key('trophy-room-$keyName-title'),
                  style: const TextStyle(
                    color: VisualPalette.courtLineWhite,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  key: Key('trophy-room-$keyName-detail'),
                  style: const TextStyle(
                    color: VisualPalette.textSoft,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null)
            TextButton(
              key: Key('trophy-room-$keyName-action'),
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: color,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(64, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              child: Text(actionLabel!),
            )
          else
            Text(
              unlocked ? 'OPEN' : 'LOCKED',
              key: Key('trophy-room-$keyName-state'),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
        ],
      ),
    );
  }
}
