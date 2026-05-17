import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/ad_provider.dart';
import '../app/app_config.dart';
import '../game/config/visual_palette.dart';
import '../services/save_service.dart';

class AdBannerSlot extends ConsumerWidget {
  const AdBannerSlot({
    required this.placement,
    super.key,
  });

  final String placement;

  static const double height = 58;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final save = ref.watch(saveDataProvider);
    if (!AppConfig.showAdPlaceholders || save.matchesCompleted == 0) {
      return const SizedBox.shrink();
    }
    final adService = ref.watch(adServiceProvider);
    if (adService.adsRemoved) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: SizedBox(
              key: Key('fake-banner-$placement'),
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: VisualPalette.scoreboardSurface.withValues(
                    alpha: 0.92,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: VisualPalette.textMuted.withValues(alpha: 0.70),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'AD',
                      style: TextStyle(
                        color: VisualPalette.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'TEST BANNER',
                      style: TextStyle(
                        color: VisualPalette.textSoft,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
