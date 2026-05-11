import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../game/config/visual_palette.dart';

class ArcadePanel extends StatelessWidget {
  const ArcadePanel({
    required this.child,
    super.key,
    this.padding = ArcadeUiTokens.panelPadding,
    this.backgroundColor = VisualPalette.uiSurface,
    this.borderColor = VisualPalette.netMeshStroke,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: ArcadeUiTokens.borderRadius,
        border: Border.all(
          color: borderColor,
          width: ArcadeUiTokens.borderWidth,
        ),
        boxShadow: ArcadeUiTokens.panelShadow,
      ),
      child: child,
    );
  }
}
