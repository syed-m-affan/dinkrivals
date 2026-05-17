import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/audio_provider.dart';
import '../app/game_provider.dart';
import '../app/router.dart';
import '../game/config/visual_palette.dart';
import '../game/models/court_unlock.dart';
import '../services/save_service.dart';
import '../widgets/arcade_button.dart';
import '../widgets/arcade_panel.dart';
import '../widgets/park_backdrop.dart';

class CourtSelectScreen extends ConsumerWidget {
  const CourtSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final save = ref.watch(saveDataProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('COURTS'),
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
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              _CourtCard(
                id: CourtUnlockIds.park,
                title: 'CLASSIC PARK',
                detail: 'Painted outdoor court',
                icon: Icons.park,
                selected: save.activeCourtId == CourtUnlockIds.park,
                onSelect: () => _selectCourt(ref, CourtUnlockIds.park),
              ),
              const SizedBox(height: 14),
              _CourtCard(
                id: CourtUnlockIds.training,
                title: 'TRAINING GRAY',
                detail: 'Projection check court',
                icon: Icons.grid_on,
                selected: save.activeCourtId == CourtUnlockIds.training,
                onSelect: () => _selectCourt(ref, CourtUnlockIds.training),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectCourt(WidgetRef ref, String courtId) async {
    ref.read(audioServiceProvider).playMenuClick();
    await ref.read(saveDataProvider.notifier).selectCourt(courtId);
    ref.read(dinkRivalsGameProvider).setSelectedCourt(courtId);
  }
}

class _CourtCard extends StatelessWidget {
  const _CourtCard({
    required this.id,
    required this.title,
    required this.detail,
    required this.icon,
    required this.selected,
    required this.onSelect,
  });

  final String id;
  final String title;
  final String detail;
  final IconData icon;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return ArcadePanel(
      backgroundColor: VisualPalette.uiSurface.withValues(alpha: 0.88),
      borderColor: selected
          ? VisualPalette.feedbackDink
          : VisualPalette.scoreboardBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: VisualPalette.uiAccent, size: 34),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      key: Key('court-$id-title'),
                      style: const TextStyle(
                        color: VisualPalette.courtLineWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      style: const TextStyle(
                        color: VisualPalette.textSoft,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                selected ? 'SELECTED' : 'OPEN',
                key: Key('court-$id-state'),
                style: TextStyle(
                  color: selected
                      ? VisualPalette.feedbackDink
                      : VisualPalette.textSoft,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ArcadeButton(
            key: Key('court-$id-select'),
            label: selected ? 'CURRENT COURT' : 'USE COURT',
            icon: selected ? Icons.check_circle : Icons.sports_tennis,
            onPressed: selected ? null : onSelect,
          ),
        ],
      ),
    );
  }
}
