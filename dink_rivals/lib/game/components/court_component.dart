import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/court_constants.dart';
import '../config/visual_palette.dart';
import '../dink_rivals_game.dart';

class CourtComponent extends Component {
  CourtComponent(this.game);

  static const String surfaceTextureAsset =
      'court/court_surface_texture_generated.png';

  final DinkRivalsGame game;
  final Paint _courtPaint = Paint()..color = VisualPalette.courtSurface;
  final Paint _courtLightPaint = Paint()
    ..color = VisualPalette.courtPlayingLight;
  final Paint _courtApronPaint = Paint()..color = VisualPalette.courtApronNavy;
  final Paint _courtApronShadePaint = Paint()
    ..color = VisualPalette.courtApronNavyShade;
  final Paint _courtShadePaint = Paint()
    ..color = VisualPalette.courtSurfaceShade;
  final Paint _linePaint = Paint()
    ..color = VisualPalette.courtLineWhite
    ..strokeCap = StrokeCap.square;
  final Paint _pixelLightPaint = Paint()..color = VisualPalette.courtPixelLight;
  final Paint _pixelDarkPaint = Paint()..color = VisualPalette.courtPixelDark;
  final Paint _scuffLightPaint = Paint()..color = VisualPalette.courtScuffLight;
  final Paint _scuffDarkPaint = Paint()..color = VisualPalette.courtScuffDark;
  final Paint _lineWearPaint = Paint()..color = VisualPalette.courtLineWear;
  final Paint _edgeShadePaint = Paint()..color = VisualPalette.courtEdgeShade;
  ui.Image? _surfaceTexture;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _surfaceTexture = await game.images.load(surfaceTextureAsset);
  }

  @override
  void render(Canvas canvas) {
    _quad(canvas, Court.top, Court.bottom, _courtApronPaint);
    _drawInnerPlayingSurface(canvas);
    _drawServicePanels(canvas);
    _drawGeneratedSurfaceTexture(canvas);
    _drawEdgeShade(canvas);
    _drawPixelTexture(canvas);
    _drawScuffs(canvas);

    _line(canvas, Vector2(Court.left, Court.top),
        Vector2(Court.right, Court.top));
    _line(canvas, Vector2(Court.left, Court.bottom),
        Vector2(Court.right, Court.bottom));
    _line(canvas, Vector2(Court.left, Court.top),
        Vector2(Court.left, Court.bottom));
    _line(canvas, Vector2(Court.right, Court.top),
        Vector2(Court.right, Court.bottom));
    _line(
      canvas,
      Vector2(Court.left, Court.opponentKitchenTopY),
      Vector2(Court.right, Court.opponentKitchenTopY),
    );
    _line(
      canvas,
      Vector2(Court.left, Court.playerKitchenBottomY),
      Vector2(Court.right, Court.playerKitchenBottomY),
    );
    _line(
      canvas,
      Vector2(Court.width / 2, Court.top),
      Vector2(Court.width / 2, Court.opponentKitchenTopY),
    );
    _line(
      canvas,
      Vector2(Court.width / 2, Court.playerKitchenBottomY),
      Vector2(Court.width / 2, Court.bottom),
    );
  }

  void _drawServicePanels(Canvas canvas) {
    const inset = 8.0;
    _quadRect(
      canvas,
      Court.left + inset,
      Court.top + inset,
      Court.width / 2,
      Court.opponentKitchenTopY,
      _courtLightPaint,
    );
    _quadRect(
      canvas,
      Court.width / 2,
      Court.top + inset,
      Court.right - inset,
      Court.opponentKitchenTopY,
      _courtPaint,
    );
    _quadRect(
      canvas,
      Court.left + inset,
      Court.playerKitchenBottomY,
      Court.width / 2,
      Court.bottom - inset,
      _courtPaint,
    );
    _quadRect(
      canvas,
      Court.width / 2,
      Court.playerKitchenBottomY,
      Court.right - inset,
      Court.bottom - inset,
      _courtLightPaint,
    );
    _quadRect(
      canvas,
      Court.left + inset,
      Court.opponentKitchenBottomY,
      Court.right - inset,
      Court.playerKitchenTopY,
      _courtShadePaint,
    );
  }

  void _drawInnerPlayingSurface(Canvas canvas) {
    const inset = 7.5;
    _quadRect(
      canvas,
      Court.left + inset,
      Court.top + inset,
      Court.right - inset,
      Court.bottom - inset,
      _courtPaint,
    );
    _quadRect(
      canvas,
      Court.left,
      Court.bottom - 12,
      Court.right,
      Court.bottom,
      _courtApronShadePaint,
    );
  }

  void _drawPixelTexture(Canvas canvas) {
    const cell = 20.0;
    const pixel = 4.0;
    for (var y = Court.top + cell; y < Court.bottom - cell; y += cell) {
      for (var x = Court.left + cell; x < Court.right - cell; x += cell) {
        final seed = (x ~/ cell) * 17 + (y ~/ cell) * 31;
        if (seed % 7 != 0) {
          continue;
        }
        final paint = seed.isEven ? _pixelLightPaint : _pixelDarkPaint;
        _quadRect(canvas, x, y, x + pixel, y + pixel, paint);
      }
    }
  }

  void _drawScuffs(Canvas canvas) {
    const scuffs = <_CourtScuff>[
      _CourtScuff(34, 68, 22, 2, true),
      _CourtScuff(158, 104, 18, 2, false),
      _CourtScuff(74, 154, 26, 3, false),
      _CourtScuff(148, 204, 16, 2, true),
      _CourtScuff(42, 304, 20, 2, false),
      _CourtScuff(128, 334, 28, 3, true),
      _CourtScuff(180, 394, 18, 2, false),
      _CourtScuff(62, 430, 24, 2, true),
    ];
    for (final scuff in scuffs) {
      _quadRect(
        canvas,
        scuff.x,
        scuff.y,
        scuff.x + scuff.width,
        scuff.y + scuff.height,
        scuff.light ? _scuffLightPaint : _scuffDarkPaint,
      );
    }
  }

  void _drawGeneratedSurfaceTexture(Canvas canvas) {
    final texture = _surfaceTexture;
    if (texture == null) {
      return;
    }
    const inset = 7.5;
    final path = _quadPath(
      Court.left + inset,
      Court.top + inset,
      Court.right - inset,
      Court.bottom - inset,
    );
    final paint = Paint()
      ..shader = ImageShader(
        texture,
        TileMode.repeated,
        TileMode.repeated,
        Float64List.fromList(const [
          1,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          1,
        ]),
      )
      ..colorFilter = const ColorFilter.mode(
        Color(0x28FFFFFF),
        BlendMode.modulate,
      );
    canvas.drawPath(path, paint);
  }

  void _drawEdgeShade(Canvas canvas) {
    const edge = 3.4;
    _quadRect(
      canvas,
      Court.left,
      Court.top,
      Court.left + edge,
      Court.bottom,
      _edgeShadePaint,
    );
    _quadRect(
      canvas,
      Court.right - edge,
      Court.top,
      Court.right,
      Court.bottom,
      _edgeShadePaint,
    );
    _quadRect(
      canvas,
      Court.left,
      Court.bottom - edge,
      Court.right,
      Court.bottom,
      _edgeShadePaint,
    );
  }

  void _quad(Canvas canvas, double topY, double bottomY, Paint paint) {
    _quadRect(canvas, Court.left, topY, Court.right, bottomY, paint);
  }

  void _quadRect(
    Canvas canvas,
    double leftX,
    double topY,
    double rightX,
    double bottomY,
    Paint paint,
  ) {
    canvas.drawPath(_quadPath(leftX, topY, rightX, bottomY), paint);
  }

  Path _quadPath(
    double leftX,
    double topY,
    double rightX,
    double bottomY,
  ) {
    final topLeft = game.courtToWorld(Vector2(leftX, topY));
    final topRight = game.courtToWorld(Vector2(rightX, topY));
    final bottomRight = game.courtToWorld(Vector2(rightX, bottomY));
    final bottomLeft = game.courtToWorld(Vector2(leftX, bottomY));
    return Path()
      ..moveTo(topLeft.x, topLeft.y)
      ..lineTo(topRight.x, topRight.y)
      ..lineTo(bottomRight.x, bottomRight.y)
      ..lineTo(bottomLeft.x, bottomLeft.y)
      ..close();
  }

  void _line(Canvas canvas, Vector2 a, Vector2 b) {
    final start = game.courtToWorld(a);
    final end = game.courtToWorld(b);
    _linePaint.strokeWidth = game.logicalToScreen(1.15).clamp(1.5, 3.0);
    canvas.drawLine(start.toOffset(), end.toOffset(), _linePaint);
    _drawLineWear(canvas, a, b);
  }

  void _drawLineWear(Canvas canvas, Vector2 a, Vector2 b) {
    final horizontal = (a.y - b.y).abs() < 0.01;
    final length = horizontal ? (a.x - b.x).abs() : (a.y - b.y).abs();
    if (length < 150) {
      return;
    }
    final startOffset = horizontal ? 52.0 : 46.0;
    for (var offset = startOffset; offset < length - 18; offset += 96) {
      final t0 = offset / length;
      final t1 = (offset + 8).clamp(0, length) / length;
      final start = Vector2(
        a.x + (b.x - a.x) * t0,
        a.y + (b.y - a.y) * t0,
      );
      final end = Vector2(
        a.x + (b.x - a.x) * t1,
        a.y + (b.y - a.y) * t1,
      );
      final worldStart = game.courtToWorld(start);
      final worldEnd = game.courtToWorld(end);
      final width = game.logicalToScreen(1.35).clamp(1.5, 3.2);
      canvas.drawLine(
        worldStart.toOffset(),
        worldEnd.toOffset(),
        _lineWearPaint
          ..strokeWidth = width
          ..strokeCap = StrokeCap.square,
      );
    }
  }
}

class _CourtScuff {
  const _CourtScuff(this.x, this.y, this.width, this.height, this.light);

  final double x;
  final double y;
  final double width;
  final double height;
  final bool light;
}
