import 'package:flutter/material.dart';

import '../game/config/environment_layout.dart';

class ParkBackdrop extends StatelessWidget {
  const ParkBackdrop({
    required this.child,
    super.key,
    this.alignment = Alignment.topCenter,
    this.overlayOpacity = 0.70,
    this.showCourtImage = true,
  });

  final Widget child;
  final Alignment alignment;
  final double overlayOpacity;
  final bool showCourtImage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (showCourtImage)
          DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage(
                  'assets/images/${EnvironmentLayout.projectionEnvironmentAsset}',
                ),
                fit: BoxFit.cover,
                alignment: alignment,
                filterQuality: FilterQuality.none,
              ),
            ),
          )
        else
          const _MenuBackdropPaint(),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(16, 21, 27, overlayOpacity * 0.72),
                Color.fromRGBO(16, 21, 27, overlayOpacity * 0.42),
                Color.fromRGBO(16, 21, 27, overlayOpacity),
              ],
              stops: const [0, 0.46, 1],
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _MenuBackdropPaint extends StatelessWidget {
  const _MenuBackdropPaint();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF14364A),
            Color(0xFF244C3B),
            Color(0xFF101B1B),
          ],
          stops: [0, 0.48, 1],
        ),
      ),
      child: CustomPaint(painter: _MenuBackdropPainter()),
    );
  }
}

class _MenuBackdropPainter extends CustomPainter {
  const _MenuBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()..color = const Color(0x332E9DCA);
    final treeDark = Paint()..color = const Color(0xAA102819);
    final treeMid = Paint()..color = const Color(0x88385A2B);
    final courtBlue = Paint()..color = const Color(0x332B76AA);
    final cream = Paint()..color = const Color(0x44F4F0D8);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.30), sky);
    for (var i = 0; i < 11; i++) {
      final x = size.width * (i / 10);
      final radius = size.width * (0.08 + (i % 3) * 0.018);
      canvas.drawCircle(Offset(x, size.height * 0.30), radius, treeDark);
      canvas.drawCircle(
        Offset(x + radius * 0.32, size.height * 0.25),
        radius * 0.72,
        treeMid,
      );
    }
    final courtRect = Rect.fromLTWH(
      size.width * 0.10,
      size.height * 0.60,
      size.width * 0.80,
      size.height * 0.26,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(courtRect, const Radius.circular(6)),
      courtBlue,
    );
    canvas.drawLine(
      Offset(courtRect.left, courtRect.top + courtRect.height * 0.42),
      Offset(courtRect.right, courtRect.top + courtRect.height * 0.42),
      cream..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(courtRect.center.dx, courtRect.top),
      Offset(courtRect.center.dx, courtRect.bottom),
      cream..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
