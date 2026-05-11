import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/debug_flags.dart';
import '../../dink_rivals_game.dart';
import '../../models/shot_type.dart';

enum VfxSprite {
  hitSpark('vfx/hit_spark.png'),
  bounceRing('vfx/bounce_ring.png'),
  trailSegment('vfx/trail_segment.png'),
  smashFlash('vfx/smash_flash.png'),
  pointBurst('vfx/point_burst.png');

  const VfxSprite(this.assetPath);

  final String assetPath;
}

class VfxLayerComponent extends Component {
  VfxLayerComponent(this.game) {
    priority = 850;
  }

  static const int _maxEffects = 18;
  static const double _trailSpawnInterval = 0.055;
  static const double _trailMinBallHeight = 24;

  final DinkRivalsGame game;
  final Map<VfxSprite, ui.Image> _sprites = {};
  final List<_ActiveVfx> _effects = [];
  double _trailCooldown = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    for (final sprite in VfxSprite.values) {
      _sprites[sprite] = await game.images.load(sprite.assetPath);
    }
  }

  @override
  void update(double dt) {
    if (!DebugFlags.useVfx) {
      _effects.clear();
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
      final width = effect.logicalSize.x * scale;
      final height = effect.logicalSize.y * scale;
      final dst = Rect.fromCenter(
        center: effect.position.toOffset(),
        width: width,
        height: height,
      );
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
    }
  }

  void spawnContact({
    required Vector2 courtPosition,
    double z = 0,
    ShotType? shotType,
  }) {
    if (!DebugFlags.useVfx) {
      return;
    }
    final isSmash = shotType == ShotType.smash;
    final sprite = isSmash ? VfxSprite.smashFlash : VfxSprite.hitSpark;
    final depthScale = game.depthScaleForY(courtPosition.y);
    _addEffect(
      _ActiveVfx(
        sprite: sprite,
        position: game.courtToWorld(courtPosition, z),
        logicalSize: Vector2.all(
          game.logicalToScreen((isSmash ? 28 : 24) * depthScale),
        ),
        lifetime: 0.16,
        startScale: 0.85,
        endScale: 1.18,
      ),
    );
  }

  void spawnBounce({required Vector2 courtPosition}) {
    if (!DebugFlags.useVfx) {
      return;
    }
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
  Iterable<String> get activeSpriteNamesForTesting =>
      _effects.map((effect) => effect.sprite.name);

  void _updateBallTrail(double dt) {
    if (!game.isLoaded || game.paused) {
      return;
    }
    _trailCooldown = (_trailCooldown - dt).clamp(0, 1).toDouble();
    final ball = game.ball.state;
    if (!ball.isInPlay || ball.z < _trailMinBallHeight || _trailCooldown > 0) {
      return;
    }
    final depthScale = game.depthScaleForY(ball.y);
    _addEffect(
      _ActiveVfx(
        sprite: VfxSprite.trailSegment,
        position: game.courtToWorld(Vector2(ball.x, ball.y), ball.z),
        logicalSize: Vector2(
          game.logicalToScreen(16 * depthScale),
          game.logicalToScreen(7 * depthScale),
        ),
        lifetime: 0.22,
        startScale: 0.86,
        endScale: 0.52,
        opacityScale: 0.48,
      ),
    );
    _trailCooldown = _trailSpawnInterval;
  }

  void _addEffect(_ActiveVfx effect) {
    _effects.add(effect);
    if (_effects.length <= _maxEffects) {
      return;
    }
    _effects.removeRange(0, _effects.length - _maxEffects);
  }
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
  });

  final VfxSprite sprite;
  final Vector2 position;
  final Vector2 logicalSize;
  final double lifetime;
  final double startScale;
  final double endScale;
  final double opacityScale;
  double age = 0;

  bool get isExpired => age >= lifetime;

  double get progress => (age / lifetime).clamp(0.0, 1.0).toDouble();
}
