import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/app_config.dart';
import '../app/audio_provider.dart';
import '../app/game_provider.dart';
import '../app/match_session_provider.dart';
import '../app/rival_challenge_provider.dart';
import '../app/router.dart';
import '../app/tournament_provider.dart';
import '../game/config/character_visuals.dart';
import '../game/config/visual_palette.dart';
import '../game/models/tournament_state.dart';
import '../services/save_service.dart';
import '../widgets/ad_banner_slot.dart';
import '../widgets/park_backdrop.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final save = ref.watch(saveDataProvider);
    final tournament = ref.watch(tournamentProvider);
    final selected = CharacterVisuals.byId(save.activeCharacterId);

    return Scaffold(
      backgroundColor: _MenuColors.ink,
      body: ParkBackdrop(
        overlayOpacity: 0.40,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxHeight < 830;
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        compact ? 10 : 14,
                        16,
                        12,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _ScoreboardHeader(),
                              SizedBox(height: compact ? 8 : 12),
                              SizedBox(
                                height: compact ? 190 : 220,
                                child: _MatchPoster(
                                  selected: selected,
                                  compact: compact,
                                ),
                              ),
                              SizedBox(height: compact ? 8 : 12),
                              _QuickMatchButton(
                                characterName: selected.displayName,
                                onPressed: () => _startQuickMatch(context, ref),
                              ),
                              const SizedBox(height: 8),
                              _ClassicCupTicket(
                                state: tournament,
                                wins: save.classicCupWins,
                                onPressed: () => _openClassicCup(context, ref),
                              ),
                              const SizedBox(height: 10),
                              _UtilityTabs(
                                onRoster: () =>
                                    _go(context, ref, AppRoutes.roster),
                                onCourts: () =>
                                    _go(context, ref, AppRoutes.courts),
                                onTrophies: () =>
                                    _go(context, ref, AppRoutes.trophyRoom),
                                onSettings: () =>
                                    _go(context, ref, AppRoutes.settings),
                              ),
                              const Spacer(),
                              if (AppConfig.showQaUi) ...[
                                const SizedBox(height: 8),
                                TextButton(
                                  key: const Key('menu-debug-rally'),
                                  onPressed: () =>
                                      _go(context, ref, AppRoutes.debugRally),
                                  child: const Text('DEBUG RALLY'),
                                ),
                                const Text(
                                  AppConfig.phaseLabel,
                                  key: Key('menu-phase-label'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: VisualPalette.textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const AdBannerSlot(placement: 'menu'),
            ],
          ),
        ),
      ),
    );
  }

  void _startQuickMatch(BuildContext context, WidgetRef ref) {
    ref.read(audioServiceProvider).playMenuClick();
    ref.read(tournamentProvider.notifier).reset();
    ref.read(rivalChallengeProvider.notifier).reset();
    final session = ref.read(matchSessionProvider.notifier).startQuickMatch();
    ref.read(dinkRivalsGameProvider).configureMatch(
          opponentCharacterId: session.opponentCharacterId,
          opponentProfile: session.opponentProfile,
        );
    context.go(AppRoutes.game);
  }

  void _openClassicCup(BuildContext context, WidgetRef ref) {
    ref.read(audioServiceProvider).playMenuClick();
    final tournament = ref.read(tournamentProvider);
    if (tournament.status == TournamentStatus.idle) {
      ref.read(tournamentProvider.notifier).startClassicCup();
    }
    context.go(AppRoutes.tournament);
  }

  void _go(BuildContext context, WidgetRef ref, String route) {
    ref.read(audioServiceProvider).playMenuClick();
    context.go(route);
  }
}

class _ScoreboardHeader extends StatelessWidget {
  const _ScoreboardHeader();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Dink Rivals',
      child: const Row(
        key: const Key('menu-wordmark'),
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CustomPaint(painter: _PickleballMarkPainter()),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DINK RIVALS',
                  maxLines: 1,
                  style: TextStyle(
                    color: _MenuColors.cream,
                    fontSize: 25,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                    shadows: [
                      Shadow(color: _MenuColors.ink, offset: Offset(2, 2)),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'PARK LEAGUE  •  SEASON 01',
                  style: TextStyle(
                    color: _MenuColors.mint,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              color: _MenuColors.inkStrong,
              border: Border.fromBorderSide(
                BorderSide(color: _MenuColors.cream, width: 1.5),
              ),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              child: Text(
                '11 PT',
                style: TextStyle(
                  color: _MenuColors.cream,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchPoster extends StatelessWidget {
  const _MatchPoster({required this.selected, required this.compact});

  final CharacterVisualDefinition selected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final portraitSize = compact ? 82.0 : 104.0;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        key: const Key('menu-match-poster'),
        constraints: BoxConstraints(maxHeight: compact ? 190 : 238),
        padding: EdgeInsets.fromLTRB(14, compact ? 10 : 16, 14, 12),
        decoration: BoxDecoration(
          color: _MenuColors.ink.withValues(alpha: 0.96),
          border: Border.all(
            color: _MenuColors.cream.withValues(alpha: 0.72),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: _MenuColors.shadow, offset: Offset(5, 5)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Text(
                  'EXHIBITION',
                  style: TextStyle(
                    color: _MenuColors.coral,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontFamily: 'monospace',
                  ),
                ),
                Spacer(),
                Text(
                  'FIRST TO 11',
                  style: TextStyle(
                    color: _MenuColors.mint,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            SizedBox(height: compact ? 7 : 11),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _PosterPlayer(
                    portraitAsset: selected.portraitAsset,
                    label: selected.displayName,
                    tag: 'YOU',
                    size: portraitSize,
                    accent: _MenuColors.mint,
                    imageKey: const Key('menu-selected-character'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    width: compact ? 42 : 48,
                    height: compact ? 42 : 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _MenuColors.coral,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _MenuColors.cream, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: _MenuColors.shadow,
                          offset: Offset(3, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      'VS',
                      style: TextStyle(
                        color: _MenuColors.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _PosterPlayer(
                    portraitAsset: CharacterVisuals.rookie.portraitAsset,
                    label: selected.id == CharacterVisuals.rookie.id
                        ? 'Rookie Bot'
                        : CharacterVisuals.rookie.displayName,
                    tag: 'CPU',
                    size: portraitSize,
                    accent: _MenuColors.coral,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PosterPlayer extends StatelessWidget {
  const _PosterPlayer({
    required this.portraitAsset,
    required this.label,
    required this.tag,
    required this.size,
    required this.accent,
    this.imageKey,
  });

  final String portraitAsset;
  final String label;
  final String tag;
  final double size;
  final Color accent;
  final Key? imageKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _MenuColors.inkStrong,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: accent, width: 2),
              ),
              child: Image.asset(
                portraitAsset,
                key: imageKey,
                filterQuality: FilterQuality.none,
              ),
            ),
            Positioned(
              left: -4,
              top: -5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                color: accent,
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: _MenuColors.ink,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _MenuColors.cream,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
          ),
        ),
      ],
    );
  }
}

class _QuickMatchButton extends StatelessWidget {
  const _QuickMatchButton({
    required this.characterName,
    required this.onPressed,
  });

  final String characterName;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.1;
    return Semantics(
      button: true,
      label: 'Quick Match, play now',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('menu-quick-match'),
          onTap: onPressed,
          borderRadius: BorderRadius.circular(7),
          child: Ink(
            height: largeText ? 84 : 72,
            decoration: BoxDecoration(
              color: _MenuColors.coral,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: _MenuColors.cream, width: 2),
              boxShadow: const [
                BoxShadow(color: _MenuColors.shadow, offset: Offset(5, 5)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CustomPaint(painter: _PlayMarkPainter()),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'QUICK MATCH',
                          maxLines: 1,
                          style: TextStyle(
                            color: _MenuColors.ink,
                            fontSize: 20,
                            height: 1,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${characterName.toUpperCase()}  /  NO STAKES',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _MenuColors.inkSoft,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'PLAY',
                    style: TextStyle(
                      color: _MenuColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClassicCupTicket extends StatelessWidget {
  const _ClassicCupTicket({
    required this.state,
    required this.wins,
    required this.onPressed,
  });

  final TournamentState state;
  final int wins;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.1;
    final action = switch (state.status) {
      TournamentStatus.idle => 'NEW CUP',
      TournamentStatus.semifinal => 'SEMIFINAL',
      TournamentStatus.finalRound => 'FINAL',
      TournamentStatus.champion => 'CHAMPION',
      TournamentStatus.eliminated => 'RESULTS',
    };
    final progress = switch (state.status) {
      TournamentStatus.idle || TournamentStatus.eliminated => 0,
      TournamentStatus.semifinal => 1,
      TournamentStatus.finalRound => 2,
      TournamentStatus.champion => 3,
    };

    return Semantics(
      button: true,
      label: 'Classic Cup, $action, unlock Showman',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('menu-tournament'),
          onTap: onPressed,
          borderRadius: BorderRadius.circular(7),
          child: Ink(
            height: largeText ? 106 : 88,
            decoration: BoxDecoration(
              color: _MenuColors.inkStrong.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: _MenuColors.gold, width: 1.5),
              boxShadow: const [
                BoxShadow(color: _MenuColors.shadow, offset: Offset(4, 4)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Image.asset(
                    CharacterVisuals.showman.portraitAsset,
                    width: 50,
                    height: 50,
                    filterQuality: FilterQuality.none,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            const Flexible(
                              child: Text(
                                'CLASSIC CUP',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _MenuColors.cream,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$wins WINS',
                              style: const TextStyle(
                                color: _MenuColors.gold,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              action,
                              key: const Key('menu-classic-cup-status'),
                              style: const TextStyle(
                                color: _MenuColors.coral,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(width: 8),
                            for (var i = 1; i <= 3; i++) ...[
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: i <= progress
                                      ? _MenuColors.mint
                                      : _MenuColors.muted.withValues(
                                          alpha: 0.36,
                                        ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              if (i < 3) const SizedBox(width: 4),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'WIN TO UNLOCK SHOWMAN',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _MenuColors.muted,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      '›',
                      style: TextStyle(
                        color: _MenuColors.gold,
                        fontSize: 30,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UtilityTabs extends StatelessWidget {
  const _UtilityTabs({
    required this.onRoster,
    required this.onCourts,
    required this.onTrophies,
    required this.onSettings,
  });

  final VoidCallback onRoster;
  final VoidCallback onCourts;
  final VoidCallback onTrophies;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _UtilityTab(
            key: const Key('menu-roster'),
            number: '01',
            label: 'ROSTER',
            onTap: onRoster,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _UtilityTab(
            key: const Key('menu-courts'),
            number: '02',
            label: 'COURTS',
            onTap: onCourts,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _UtilityTab(
            key: const Key('menu-trophy-room'),
            number: '03',
            label: 'TROPHIES',
            onTap: onTrophies,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _UtilityTab(
            key: const Key('menu-settings'),
            number: '04',
            label: 'SETTINGS',
            onTap: onSettings,
          ),
        ),
      ],
    );
  }
}

class _UtilityTab extends StatelessWidget {
  const _UtilityTab({
    required this.number,
    required this.label,
    required this.onTap,
    super.key,
  });

  final String number;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(5),
          child: Ink(
            height: 58,
            decoration: BoxDecoration(
              color: _MenuColors.inkStrong.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: _MenuColors.cream.withValues(alpha: 0.38),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    number,
                    style: const TextStyle(
                      color: _MenuColors.mint,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 5),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: const TextStyle(
                        color: _MenuColors.cream,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickleballMarkPainter extends CustomPainter {
  const _PickleballMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.43;
    canvas.drawCircle(
      center + const Offset(2, 2),
      radius,
      Paint()..color = _MenuColors.shadow,
    );
    canvas.drawCircle(center, radius, Paint()..color = _MenuColors.gold);
    final hole = Paint()..color = _MenuColors.ink;
    final holeRadius = radius * 0.12;
    for (final offset in const [
      Offset(-0.36, -0.34),
      Offset(0.25, -0.42),
      Offset(-0.08, 0.02),
      Offset(0.42, 0.16),
      Offset(-0.37, 0.38),
      Offset(0.10, 0.48),
    ]) {
      canvas.drawCircle(
        center + Offset(offset.dx * radius, offset.dy * radius),
        holeRadius,
        hole,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlayMarkPainter extends CustomPainter {
  const _PlayMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.15)
      ..lineTo(size.width * 0.82, size.height * 0.50)
      ..lineTo(size.width * 0.25, size.height * 0.85)
      ..close();
    canvas.drawPath(path, Paint()..color = _MenuColors.ink);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MenuColors {
  static const ink = Color(0xFF07171C);
  static const inkStrong = Color(0xFF0A242A);
  static const inkSoft = Color(0xFF17343A);
  static const cream = Color(0xFFFFF0C7);
  static const coral = Color(0xFFFF6B43);
  static const mint = Color(0xFF69E1C0);
  static const gold = Color(0xFFF2CA62);
  static const muted = Color(0xFF91A5A6);
  static const shadow = Color(0xB800090C);
}
