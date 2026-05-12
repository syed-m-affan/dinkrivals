import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/court_constants.dart';
import '../config/debug_flags.dart';
import '../config/environment_layout.dart';
import '../config/visual_palette.dart';
import '../dink_rivals_game.dart';
import '../util/projected_shadow.dart';

class ClassicEnvironmentComponent extends Component {
  ClassicEnvironmentComponent(this.game) {
    priority = -1000;
  }

  final DinkRivalsGame game;
  final Map<String, ui.Image> _images = {};
  ui.Image? _generatedBackground;
  ui.Image? _softShadow;

  final Paint _groundPaint = Paint()..color = VisualPalette.environmentGround;
  final Paint _apronPaint = Paint()..color = VisualPalette.environmentApron;
  final Paint _apronLinePaint = Paint()
    ..color = VisualPalette.environmentApronLine
    ..style = PaintingStyle.stroke;
  final Paint _courtShadowPaint = Paint()
    ..color = VisualPalette.courtOuterShadow;
  final Paint _foliageShadowPaint = Paint()
    ..color = VisualPalette.environmentFoliageShadow;
  final Paint _foliageMidPaint = Paint()
    ..color = VisualPalette.environmentFoliageMid;
  final Paint _foliageLightPaint = Paint()
    ..color = VisualPalette.environmentFoliageLight;
  final Paint _quietControlPaint = Paint()
    ..color = VisualPalette.environmentControlQuiet;
  final Paint _farShadePaint = Paint()
    ..color = VisualPalette.environmentBackWall;
  final Paint _farTreeDarkPaint = Paint()
    ..color = VisualPalette.environmentTreeLineBack;
  final Paint _farTreeMidPaint = Paint()
    ..color = VisualPalette.environmentTreeLineMid;
  final Paint _farTreeLightPaint = Paint()
    ..color = VisualPalette.environmentTreeLineLight;
  final Paint _fenceRailPaint = Paint()
    ..color = VisualPalette.environmentFenceRail
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.square;
  final Paint _fenceMeshPaint = Paint()
    ..color = VisualPalette.environmentFenceMesh
    ..style = PaintingStyle.stroke;
  final Paint _fencePostPaint = Paint()
    ..color = VisualPalette.environmentFencePost;
  final Paint _apronFeatherPaint = Paint()
    ..color = VisualPalette.environmentApronFeather;
  final Paint _apronContactPaint = Paint()
    ..color = VisualPalette.environmentApronContact;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _generatedBackground =
        await game.images.load(EnvironmentLayout.generatedBackgroundAsset);
    _softShadow = await game.images.load(EnvironmentLayout.softShadowAsset);
    for (final prop in EnvironmentLayout.classicProps) {
      _images[prop.assetPath] = await game.images.load(prop.assetPath);
    }
  }

  @override
  void render(Canvas canvas) {
    final hasGeneratedBackground = _drawGeneratedBackgroundBase(canvas);
    if (!hasGeneratedBackground) {
      // Legacy fallback: only used when the painted bg fails to load. The
      // generated background already contains apron, court, foliage, fence,
      // sky, and contact shadow, so when it is present we skip all of the
      // synthetic overlays that used to dim the painted court.
      _drawGround(canvas);
      _drawBackTreeLine(canvas);
      _drawBackFenceBand(canvas);
      _drawCourtApron(canvas);
    }
    final props = [...EnvironmentLayout.classicProps]
      ..sort((a, b) => a.courtAnchor.y.compareTo(b.courtAnchor.y));
    for (final prop in props) {
      _drawProp(canvas, prop);
    }
  }

  bool _drawGeneratedBackgroundBase(Canvas canvas) {
    final image = _generatedBackground;
    if (image == null) {
      return false;
    }
    final screen = Offset.zero & game.size.toSize();
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final scale = math.max(
      screen.width / imageSize.width,
      screen.height / imageSize.height,
    );
    final fitted = Size(imageSize.width * scale, imageSize.height * scale);
    final dst = Rect.fromLTWH(
      (screen.width - fitted.width) / 2,
      (screen.height - fitted.height) / 2,
      fitted.width,
      fitted.height,
    );
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      dst,
      Paint()..filterQuality = FilterQuality.none,
    );
    return true;
  }

  void _drawGround(Canvas canvas) {
    final rect = Offset.zero & game.size.toSize();
    canvas.drawRect(rect, _groundPaint);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            VisualPalette.environmentGroundCool,
            VisualPalette.environmentGround,
            VisualPalette.environmentGroundWarm,
          ],
          stops: [0, 0.58, 1],
        ).createShader(rect),
    );
    _drawSubtleGroundTexture(canvas);
    _drawControlQuieting(canvas);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, game.size.x, game.size.y * 0.26),
      _farShadePaint,
    );
    _drawFoliageEdges(canvas);
  }

  void _drawCourtApron(Canvas canvas) {
    final feather = _courtPath(margin: 58);
    canvas.drawPath(feather, _apronFeatherPaint);

    final outer = _courtPath(margin: 36);
    canvas.save();
    canvas.translate(game.logicalToScreen(4), game.logicalToScreen(12));
    canvas.drawPath(outer, _courtShadowPaint);
    canvas.restore();
    canvas.drawPath(outer, _apronPaint);

    final contact = _courtPath(margin: 8);
    canvas.save();
    canvas.translate(game.logicalToScreen(1.5), game.logicalToScreen(3.5));
    canvas.drawPath(contact, _apronContactPaint);
    canvas.restore();

    _apronLinePaint.strokeWidth = game.logicalToScreen(0.55).clamp(0.8, 1.4);
    for (var y = Court.top - 28.0; y <= Court.bottom + 30; y += 34) {
      _drawApronLine(
        canvas,
        Vector2(Court.left - 32, y),
        Vector2(Court.right + 32, y),
      );
    }
    for (var x = Court.left - 30.0; x <= Court.right + 32; x += 34) {
      _drawApronLine(
        canvas,
        Vector2(x, Court.top - 32),
        Vector2(x, Court.bottom + 32),
      );
    }
  }

  void _drawBackTreeLine(Canvas canvas) {
    final baseY = game.size.y * 0.105;
    final radius = game.logicalToScreen(24).clamp(18, 34).toDouble();
    for (var i = -1; i <= 10; i++) {
      final x = game.size.x * (i / 9.0) + (i.isEven ? -8 : 10);
      final y = baseY + (i % 3) * radius * 0.18;
      _drawLayeredTree(canvas, Offset(x, y), radius * (1 + (i % 4) * 0.08));
    }
    final hedgeY = game.size.y * 0.165;
    final hedgePaint = Paint()..color = VisualPalette.environmentHedge;
    for (var x = -radius; x < game.size.x + radius; x += radius * 0.72) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, hedgeY + ((x / radius).round().isEven ? 2 : -3)),
          width: radius * 1.12,
          height: radius * 0.55,
        ),
        hedgePaint,
      );
    }
  }

  void _drawLayeredTree(Canvas canvas, Offset center, double radius) {
    final trunkPaint = Paint()..color = VisualPalette.environmentTreeTrunk;
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx - radius * 0.08,
        center.dy + radius * 0.30,
        radius * 0.16,
        radius * 0.72,
      ),
      trunkPaint,
    );
    canvas.drawCircle(center, radius, _farTreeDarkPaint);
    canvas.drawCircle(
      center.translate(radius * 0.40, radius * 0.03),
      radius * 0.78,
      _farTreeMidPaint,
    );
    canvas.drawCircle(
      center.translate(radius * 0.05, -radius * 0.30),
      radius * 0.50,
      _farTreeLightPaint,
    );
  }

  void _drawBackFenceBand(Canvas canvas) {
    final left = game.courtToWorld(Vector2(Court.left - 70, Court.top - 26));
    final right = game.courtToWorld(Vector2(Court.right + 70, Court.top - 26));
    final lowerLeft =
        game.courtToWorld(Vector2(Court.left - 70, Court.top + 2));
    final lowerRight =
        game.courtToWorld(Vector2(Court.right + 70, Court.top + 2));
    final height = (lowerLeft.y - left.y).abs().clamp(16, 28).toDouble();
    final topY = left.y;
    final bottomY = topY + height;
    final minX = left.x;
    final maxX = right.x;
    _fenceRailPaint.strokeWidth = game.logicalToScreen(0.9).clamp(1, 1.8);
    _fenceMeshPaint.strokeWidth = game.logicalToScreen(0.45).clamp(0.65, 1.0);
    canvas.drawLine(Offset(minX, topY), Offset(maxX, topY), _fenceRailPaint);
    canvas.drawLine(
      Offset(lowerLeft.x, bottomY),
      Offset(lowerRight.x, bottomY),
      _fenceRailPaint,
    );

    final postWidth = game.logicalToScreen(2.4).clamp(2, 4).toDouble();
    final postGap = game.logicalToScreen(18).clamp(16, 28).toDouble();
    for (var x = minX; x <= maxX + 0.1; x += postGap) {
      canvas.drawRect(
        Rect.fromLTWH(x - postWidth / 2, topY - postWidth, postWidth, height),
        _fencePostPaint,
      );
    }
    for (var x = minX - postGap; x < maxX; x += postGap) {
      canvas.drawLine(
        Offset(x, bottomY),
        Offset(x + postGap, topY),
        _fenceMeshPaint,
      );
      canvas.drawLine(
        Offset(x, topY),
        Offset(x + postGap, bottomY),
        _fenceMeshPaint,
      );
    }
  }

  Path _courtPath({required double margin}) {
    final topLeft =
        game.courtToWorld(Vector2(Court.left - margin, Court.top - margin));
    final topRight =
        game.courtToWorld(Vector2(Court.right + margin, Court.top - margin));
    final bottomRight =
        game.courtToWorld(Vector2(Court.right + margin, Court.bottom + margin));
    final bottomLeft =
        game.courtToWorld(Vector2(Court.left - margin, Court.bottom + margin));
    return Path()
      ..moveTo(topLeft.x, topLeft.y)
      ..lineTo(topRight.x, topRight.y)
      ..lineTo(bottomRight.x, bottomRight.y)
      ..lineTo(bottomLeft.x, bottomLeft.y)
      ..close();
  }

  void _drawApronLine(Canvas canvas, Vector2 a, Vector2 b) {
    final start = game.courtToWorld(a);
    final end = game.courtToWorld(b);
    canvas.drawLine(start.toOffset(), end.toOffset(), _apronLinePaint);
  }

  void _drawSubtleGroundTexture(Canvas canvas) {
    final step = game.logicalToScreen(22).clamp(16, 28).toDouble();
    final dot = game.logicalToScreen(1.2).clamp(1, 2).toDouble();
    final paint = Paint()..color = const Color(0x1A22381F);
    final patchPaint = Paint()..color = const Color(0x182D4326);
    for (var y = step; y < game.size.y; y += step) {
      for (var x = step * 0.5; x < game.size.x; x += step) {
        final seed = ((x / step).floor() * 11 + (y / step).floor() * 17);
        if (seed % 5 != 0) {
          continue;
        }
        canvas.drawRect(Rect.fromLTWH(x, y, dot, dot), paint);
        if (seed % 13 == 0) {
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(x + step * 0.35, y + step * 0.2),
              width: step * 1.2,
              height: step * 0.38,
            ),
            patchPaint,
          );
        }
      }
    }
  }

  void _drawFoliageEdges(Canvas canvas) {
    final radius = game.logicalToScreen(34).clamp(24, 52).toDouble();
    final clusters = <Offset>[
      Offset(-radius * 0.10, game.size.y * 0.06),
      Offset(game.size.x * 0.16, game.size.y * 0.03),
      Offset(game.size.x * 0.84, game.size.y * 0.04),
      Offset(game.size.x + radius * 0.10, game.size.y * 0.10),
      Offset(-radius * 0.25, game.size.y * 0.42),
      Offset(game.size.x + radius * 0.20, game.size.y * 0.46),
      Offset(radius * 0.20, game.size.y * 0.90),
      Offset(game.size.x - radius * 0.25, game.size.y * 0.86),
    ];
    for (final center in clusters) {
      _drawFoliageCluster(canvas, center, radius);
    }
  }

  void _drawFoliageCluster(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius, _foliageShadowPaint);
    canvas.drawCircle(
      center.translate(radius * 0.48, radius * 0.16),
      radius * 0.72,
      _foliageMidPaint,
    );
    canvas.drawCircle(
      center.translate(radius * 0.08, -radius * 0.28),
      radius * 0.46,
      _foliageLightPaint,
    );
  }

  void _drawControlQuieting(Canvas canvas) {
    final center = Offset(game.size.x * 0.5, game.size.y * 0.92);
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: game.size.x * 1.25,
        height: game.size.y * 0.32,
      ),
      _quietControlPaint,
    );
  }

  void _drawProp(Canvas canvas, EnvironmentPropPlacement prop) {
    final image = _images[prop.assetPath];
    if (image == null) {
      return;
    }
    final anchor = game.courtToWorld(prop.courtAnchor);
    final depthScale = game.depthScaleForY(prop.courtAnchor.y);
    final width = game.logicalToScreen(prop.logicalSize.x * depthScale);
    final height = game.logicalToScreen(prop.logicalSize.y * depthScale);
    final size = ClassicEnvironmentGeometry.propSize(
      imageWidth: image.width.toDouble(),
      imageHeight: image.height.toDouble(),
      width: width,
      height: height,
      preserveAspect: prop.preserveAspect,
    );
    final dst = ClassicEnvironmentGeometry.propRect(
      anchor: anchor,
      width: size.width,
      height: size.height,
      propAnchor: prop.anchor,
    );
    _drawPropShadow(canvas, prop, anchor, size.width);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      dst,
      Paint()
        ..filterQuality = FilterQuality.none
        ..colorFilter = ColorFilter.mode(
          Color.fromRGBO(255, 255, 255, prop.opacity),
          BlendMode.modulate,
        ),
    );
  }

  void _drawPropShadow(
    Canvas canvas,
    EnvironmentPropPlacement prop,
    Vector2 anchor,
    double propWidth,
  ) {
    if (!DebugFlags.useProjectedShadows) {
      return;
    }
    final shadow = _softShadow;
    if (shadow == null || prop.anchor != EnvironmentPropAnchor.bottomCenter) {
      return;
    }
    final width = propWidth * 0.74;
    final height = width * shadow.height / shadow.width;
    final dst = ProjectedShadow.directionalOvalRect(
      center: anchor.toOffset(),
      width: width,
      height: height,
      offsetScale: 1.05,
    );
    canvas.drawImageRect(
      shadow,
      Rect.fromLTWH(0, 0, shadow.width.toDouble(), shadow.height.toDouble()),
      dst,
      Paint()
        ..filterQuality = FilterQuality.none
        ..colorFilter = const ColorFilter.mode(
          Color.fromRGBO(255, 255, 255, 0.82),
          BlendMode.modulate,
        ),
    );
  }
}

class ClassicEnvironmentGeometry {
  const ClassicEnvironmentGeometry._();

  static Size propSize({
    required double imageWidth,
    required double imageHeight,
    required double width,
    required double height,
    required bool preserveAspect,
  }) {
    if (!preserveAspect || imageWidth <= 0 || imageHeight <= 0) {
      return Size(width, height);
    }
    final imageAspect = imageWidth / imageHeight;
    final requestedAspect = width / height;
    if (requestedAspect > imageAspect) {
      return Size(height * imageAspect, height);
    }
    return Size(width, width / imageAspect);
  }

  static Rect propRect({
    required Vector2 anchor,
    required double width,
    required double height,
    required EnvironmentPropAnchor propAnchor,
  }) {
    return switch (propAnchor) {
      EnvironmentPropAnchor.center => Rect.fromCenter(
          center: anchor.toOffset(),
          width: width,
          height: height,
        ),
      EnvironmentPropAnchor.bottomCenter => Rect.fromLTWH(
          anchor.x - width / 2,
          anchor.y - height,
          width,
          height,
        ),
    };
  }
}
