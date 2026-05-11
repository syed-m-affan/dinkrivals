import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/audio_provider.dart';
import '../app/router.dart';
import '../game/config/visual_palette.dart';

class _CharacterDef {
  const _CharacterDef({
    required this.name,
    required this.role,
    required this.strength,
    required this.weakness,
    required this.portraitAsset,
  });

  final String name;
  final String role;
  final String strength;
  final String weakness;
  final String portraitAsset;
}

const _mvpRoster = <_CharacterDef>[
  _CharacterDef(
    name: 'Rookie',
    role: 'Default balanced player',
    strength: 'Easy control',
    weakness: 'No specialty',
    portraitAsset: 'assets/images/ui/portrait_rookie.png',
  ),
  _CharacterDef(
    name: 'Rally Queen',
    role: 'Dink / control specialist',
    strength: 'Soft game',
    weakness: 'Lower power',
    portraitAsset: 'assets/images/ui/portrait_rally_queen.png',
  ),
  _CharacterDef(
    name: 'Veteran',
    role: 'Defensive placement',
    strength: 'Consistency',
    weakness: 'Slower speed',
    portraitAsset: 'assets/images/ui/portrait_veteran.png',
  ),
  _CharacterDef(
    name: 'Showman',
    role: 'Aggressive flashy player',
    strength: 'Power / specials',
    weakness: 'Less consistent',
    portraitAsset: 'assets/images/ui/portrait_showman.png',
  ),
];

class RosterScreen extends ConsumerWidget {
  const RosterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _mvpRoster.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final char = _mvpRoster[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: VisualPalette.uiSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: VisualPalette.netMeshStroke),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    char.portraitAsset,
                    key: Key('roster-portrait-${char.name}'),
                    width: 72,
                    height: 72,
                    filterQuality: FilterQuality.none,
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
                          char.role,
                          style: const TextStyle(
                            color: VisualPalette.courtLineWhite,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Strength: ${char.strength}'),
                        Text('Weakness: ${char.weakness}'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
