import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../game/config/visual_palette.dart';

class ArcadeButton extends StatelessWidget {
  const ArcadeButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        onPressed == null ? VisualPalette.textMuted : VisualPalette.textPrimary;
    final backgroundColor = onPressed == null
        ? VisualPalette.controlSurfaceDisabled
        : VisualPalette.environmentSignPanelAlt;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: compact ? 44 : 54,
        minWidth: compact ? 96 : 180,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: ArcadeUiTokens.borderRadius,
          border: Border.all(
            color: VisualPalette.uiAccent,
            width: ArcadeUiTokens.borderWidth,
          ),
          boxShadow: ArcadeUiTokens.panelShadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: ArcadeUiTokens.borderRadius,
          child: InkWell(
            borderRadius: ArcadeUiTokens.borderRadius,
            onTap: onPressed,
            child: DefaultTextStyle(
              style: ArcadeUiTokens.labelTextStyle.copyWith(
                color: foregroundColor,
              ),
              child: Padding(
                padding: compact
                    ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
                    : ArcadeUiTokens.buttonPadding,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: ArcadeUiTokens.borderRadius,
                    border: Border.all(
                      color:
                          VisualPalette.courtLineWhite.withValues(alpha: 0.18),
                      width: ArcadeUiTokens.innerHighlightWidth,
                    ),
                  ),
                  child: Center(child: child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
