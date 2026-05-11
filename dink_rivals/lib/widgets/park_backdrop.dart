import 'package:flutter/material.dart';

class ParkBackdrop extends StatelessWidget {
  const ParkBackdrop({
    required this.child,
    super.key,
    this.alignment = Alignment.topCenter,
    this.overlayOpacity = 0.70,
  });

  final Widget child;
  final Alignment alignment;
  final double overlayOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage(
                'assets/images/environment/classic/park_background_overhaul.png',
              ),
              fit: BoxFit.cover,
              alignment: alignment,
              filterQuality: FilterQuality.none,
            ),
          ),
        ),
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
