import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/debug_flags.dart';
import '../../config/tuning_constants.dart';
import '../../dink_rivals_game.dart';
import '../../models/player_state.dart';
import '../../models/shot_type.dart';
import '../../models/swing_intent.dart';
import '../../systems/shot_system.dart';
import '../ball_component.dart';

enum VfxSprite {
  dinkSpark('vfx/dink_spark_generated.png'),
  driveArc('vfx/drive_arc_generated.png'),
  lobArc('vfx/lob_arc_generated.png'),
  smashBand('vfx/smash_band_generated.png'),
  missWhiff('vfx/miss_whiff_generated.png'),
  bounceRing('vfx/bounce_ring_generated.png'),
  trailSegment('vfx/trail_segment_generated.png'),
  pointBurst('vfx/point_burst_generated.png');

  const VfxSprite(this.assetPath);

  final String assetPath;
}

class VfxLayerComponent extends Component {
  VfxLayerComponent(this.game) {
    priority = 850;
  }

  static const int _maxEffects = 18;
  static const int _maxTrailSamples = 12;
  static const double _trailSampleInterval = 0.045;
  static const double _trailMinBallHeight = 10;

  final DinkRivalsGame game;
  final Map<VfxSprite, ui.Image> _sprites = {};
  final List<_ActiveVfx> _effects = [];
  final List<_TrailSample> _trailSamples = List<_TrailSample>.generate(
    _maxTrailSamples,
    (_) => _TrailSample(),
  );
  double _trailCooldown = 0;
  int _trailWriteIndex = 0;
  int _trailCount = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    for (final sprite in VfxSprite.values) {
      _sprites[sprite] = await game.images.load(sprite.assetPath);
    }
  }

  @override
  void update(double dt) {
    if (game.isLoaded) {
      priority = game.ball.state.y.round();
    }
    if (!DebugFlags.useVfx) {
      _effects.clear();
      clearBallTrail();
      return;
    }
    for (final effect in _effects) {
      effect.age += dt;
    }
    _effects.removeWhere((effect) => effect.isExpired);
    _updateBallTrail(dt);
  }

  @override
  void render(Canvas canvas) {
    if (!DebugFlags.useVfx) {
      return;
    }
    _renderBallTrail(canvas);
    for (final effect in _effects) {
      final image = _sprites[effect.sprite];
      if (image == null) {
        continue;
      }
      final progress = effect.progress;
      final opacity =
          ((1 - progress) * (1 - progress) * effect.opacityScale).clamp(
        0.0,
        1.0,
      );
      final scale =
          effect.startScale + (effect.endScale - effect.startScale) * progress;
      final dst = Rect.fromCenter(
        center: Offset.zero,
        width: effect.logicalSize.x * scale,
        height: effect.logicalSize.y * scale,
      );
      canvas.save();
      canvas.translate(effect.position.x, effect.position.y);
      canvas.rotate(effect.angle);
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        dst,
        Paint()
          ..filterQuality = FilterQuality.none
          ..colorFilter = ColorFilter.mode(
            Color.fromRGBO(255, 255, 255, opacity),
            BlendMode.modulate,
          ),
      );
      canvas.restore();
    }
  }

  void spawnContact({
    required Vector2 courtPosition,
    double z = 0,
    ShotType? shotType,
    Vector2? shotVelocity,
  }) {
    if (!DebugFlags.useVfx) {
      return;
    }
    clearBallTrail();
    final isSmash = shotType == ShotType.smash;
    final isLob = shotType == ShotType.lob;
    final isDrive = shotType == ShotType.drive || shotType == ShotType.serve;
    final depthScale = game.depthScaleForY(courtPosition.y);
    final shotAngle = shotVelocity == null || shotVelocity.length2 < 0.01
        ? 0.0
        : math.atan2(shotVelocity.y, shotVelocity.x);
    _addEffect(
      _ActiveVfx(
        sprite: _contactSpriteFor(shotType),
        position: game.courtToWorld(courtPosition, z),
        logicalSize: Vector2(
          game.logicalToScreen(
            (isSmash
                    ? 34
                    : isDrive
                        ? 30
                        : isLob
                            ? 28
                            : 22) *
                depthScale,
          ),
          game.logicalToScreen(
            (isDrive
                    ? 16
                    : isLob
                        ? 18
                        : isSmash
                            ? 34
                            : 22) *
                depthScale,
          ),
        ),
        lifetime: isLob ? 0.20 : 0.16,
        startScale: 0.85,
        endScale: isDrive ? 1.32 : 1.18,
        angle: switch (shotType) {
          ShotType.drive || ShotType.serve => shotAngle,
          ShotType.lob => -math.pi / 2,
          _ => 0,
        },
      ),
    );
  }

  void spawnSwingMiss({
    required PlayerState hitter,
    required SwingIntent intent,
    required Vector2 swipeDirection,
  }) {
    if (!DebugFlags.useVfx) {
      return;
    }
    final path = ShotSystem.committedSwingPath(
      hitter: hitter,
      intent: intent,
      swipeDirection: swipeDirection,
    );
    final center = (path.start + path.end) * 0.5;
    final delta = path.end - path.start;
    final depthScale = game.depthScaleForY(hitter.position.y);
    final isVertical = intent == SwingIntent.lob || intent == SwingIntent.smash;
    _addEffect(
      _ActiveVfx(
        sprite: VfxSprite.missWhiff,
        position: game.courtToWorld(center, Tuning.racketContactZ),
        logicalSize: Vector2(
          game.logicalToScreen((isVertical ? 16 : 34) * depthScale),
          game.logicalToScreen((isVertical ? 34 : 13) * depthScale),
        ),
        lifetime: 0.20,
        startScale: 0.92,
        endScale: 1.15,
        opacityScale: 0.58,
        angle: delta.length2 < 0.01 ? 0 : math.atan2(delta.y, delta.x),
      ),
    );
  }

  void spawnBounce({required Vector2 courtPosition}) {
    if (!DebugFlags.useVfx) {
      return;
    }
    clearBallTrail();
    final depthScale = game.depthScaleForY(courtPosition.y);
    _addEffect(
      _ActiveVfx(
        sprite: VfxSprite.bounceRing,
        position: game.courtToWorld(courtPosition),
        logicalSize: Vector2(
          game.logicalToScreen(26 * depthScale),
          game.logicalToScreen(10),
        ),
        lifetime: 0.18,
        startScale: 0.8,
        endScale: 1.16,
      ),
    );
  }

  void spawnPointBurst({required Vector2 courtPosition}) {
    if (!DebugFlags.useVfx) {
      return;
    }
    _addEffect(
      _ActiveVfx(
        sprite: VfxSprite.pointBurst,
        position: game.courtToWorld(courtPosition, 18),
        logicalSize: Vector2(
          game.logicalToScreen(44),
          game.logicalToScreen(26),
        ),
        lifetime: 0.42,
        startScale: 0.78,
        endScale: 1.18,
        opacityScale: 0.88,
      ),
    );
  }

  @visibleForTesting
  int get activeEffectCountForTesting => _effects.length;

  @visibleForTesting
  int get activeTrailSampleCountForTesting => _trailCount;

  @visibleForTesting
  void addTrailSampleForTesting(Vector2 position) {
    _addTrailSample(
      position: position,
      logicalSize: Vector2(20, 9),
      angle: 0,
    );
  }

  @visibleForTesting
  Iterable<String> get activeSpriteNamesForTesting =>
      _effects.map((effect) => effect.sprite.name);

  void clearBallTrail() {
    _trailCount = 0;
    _trailWriteIndex = 0;
    _trailCooldown = 0;
  }

  void _updateBallTrail(double dt) {
    if (!game.isLoaded || game.paused) {
      return;
    }
    _trailCooldown = (_trailCooldown - dt).clamp(0, 1).toDouble();
    final ball = game.ball.state;
    if (!ball.isInPlay || ball.z < _trailMinBallHeight) {
      clearBallTrail();
      return;
    }
    if (_trailCooldown > 0) {
      return;
    }
    final current = game.courtToWorld(Vector2(ball.x, ball.y), ball.z);
    final previous = game.courtToWorld(
      Vector2(
        ball.x - ball.vx * _trailSampleInterval,
        ball.y - ball.vy * _trailSampleInterval,
      ),
      math.max(0, ball.z - ball.vz * _trailSampleInterval),
    );
    final delta = current - previous;
    final angle = delta.length2 < 0.01 ? 0.0 : math.atan2(delta.y, delta.x);
    final depthScale = game.depthScaleForY(ball.y);
    final radius = game.logicalToScreen(
      BallComponent.visualRadiusFor(ball.z, depthScale),
    );
    _addTrailSample(
      position: current,
      logicalSize: Vector2(
        (radius * 2.5).clamp(5.0, 18.0).toDouble(),
        (radius * 1.05).clamp(3.0, 9.0).toDouble(),
      ),
      angle: angle,
    );
    _trailCooldown = _trailSampleInterval;
  }

  void _addTrailSample({
    required Vector2 position,
    required Vector2 logicalSize,
    required double angle,
  }) {
    _trailSamples[_trailWriteIndex]
      ..position.setFrom(position)
      ..logicalSize.setFrom(logicalSize)
      ..angle = angle;
    _trailWriteIndex = (_trailWriteIndex + 1) % _maxTrailSamples;
    _trailCount = (_trailCount + 1).clamp(0, _maxTrailSamples);
  }

  void _renderBallTrail(Canvas canvas) {
    final image = _sprites[VfxSprite.trailSegment];
    if (image == null || _trailCount == 0) {
      return;
    }
    for (var i = 0; i < _trailCount; i += 1) {
      final sampleIndex =
          (_trailWriteIndex - 1 - i + _maxTrailSamples) % _maxTrailSamples;
      final sample = _trailSamples[sampleIndex];
      final fade = (1 - i / _maxTrailSamples).clamp(0.0, 1.0).toDouble();
      final opacity = 0.58 * fade * fade;
      final scale = 1.0 - i * 0.035;
      final dst = Rect.fromCenter(
        center: Offset.zero,
        width: sample.logicalSize.x * scale,
        height: sample.logicalSize.y * scale,
      );
      canvas.save();
      canvas.translate(sample.position.x, sample.position.y);
      canvas.rotate(sample.angle);
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        dst,
        Paint()
          ..filterQuality = FilterQuality.none
          ..colorFilter = ColorFilter.mode(
            Color.fromRGBO(255, 255, 255, opacity),
            BlendMode.modulate,
          ),
      );
      canvas.restore();
    }
  }

  void _addEffect(_ActiveVfx effect) {
    _effects.add(effect);
    if (_effects.length <= _maxEffects) {
      return;
    }
    _effects.removeRange(0, _effects.length - _maxEffects);
  }

  VfxSprite _contactSpriteFor(ShotType? shotType) {
    return switch (shotType) {
      ShotType.drive || ShotType.serve => VfxSprite.driveArc,
      ShotType.lob => VfxSprite.lobArc,
      ShotType.smash => VfxSprite.smashBand,
      ShotType.dink || ShotType.block || null => VfxSprite.dinkSpark,
    };
  }
}

class _TrailSample {
  final Vector2 position = Vector2.zero();
  final Vector2 logicalSize = Vector2.zero();
  double angle = 0;
}

class _ActiveVfx {
  _ActiveVfx({
    required this.sprite,
    required this.position,
    required this.logicalSize,
    required this.lifetime,
    required this.startScale,
    required this.endScale,
    this.opacityScale = 1,
    this.angle = 0,
  });

  final VfxSprite sprite;
  final Vector2 position;
  final Vector2 logicalSize;
  final double lifetime;
  final double startScale;
  final double endScale;
  final double opacityScale;
  final double angle;
  double age = 0;

  bool get isExpired => age >= lifetime;

  double get progress => (age / lifetime).clamp(0.0, 1.0).toDouble();
}
