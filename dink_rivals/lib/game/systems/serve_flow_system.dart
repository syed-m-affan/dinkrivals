import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../config/court_constants.dart';
import '../config/tuning_constants.dart';
import '../models/ball_state.dart';
import '../models/match_state.dart';
import '../models/opponent_serve_phase.dart';
import '../models/player_side.dart';
import '../models/player_state.dart';
import '../models/shot_type.dart';
import 'shot_system.dart';

class ServeFlowSystem {
  ServeFlowSystem({math.Random? random}) : _random = random ?? math.Random();

  static const double opponentServeCountdownSeconds = 3.0;

  final math.Random _random;
  final ValueNotifier<OpponentServePhase> opponentServePhase =
      ValueNotifier<OpponentServePhase>(OpponentServePhase.none);
  final ValueNotifier<int> opponentServeCountdown = ValueNotifier<int>(0);

  Vector2 _opponentServeDirection = Vector2(0, 1);
  double _opponentServeSecondsRemaining = 0;
  double _playerServeChargeSeconds = 0;
  int? _playerServePointerId;

  bool get hasActivePlayerServeCharge => _playerServePointerId != null;

  bool ownsPlayerServePointer(int pointerId) {
    return pointerId == _playerServePointerId;
  }

  double get playerServeChargeFraction =>
      (_playerServeChargeSeconds / Tuning.serveChargeDuration)
          .clamp(0.0, 1.0)
          .toDouble();

  bool isWaitingForPlayerServe({
    required BallState ball,
    required MatchState matchState,
  }) {
    return !ball.isInPlay &&
        !matchState.matchOver &&
        matchState.servingSide == PlayerSide.player &&
        opponentServePhase.value == OpponentServePhase.none;
  }

  bool beginPlayerServeCharge({
    required int pointerId,
    required bool isWaitingToServe,
    required bool paused,
  }) {
    if (!isWaitingToServe || paused || _playerServePointerId != null) {
      return false;
    }
    _playerServePointerId = pointerId;
    _playerServeChargeSeconds = 0;
    return true;
  }

  void updatePlayerServeCharge(double dt) {
    if (_playerServePointerId == null) {
      return;
    }
    _playerServeChargeSeconds = math.min(
      Tuning.serveChargeDuration,
      _playerServeChargeSeconds + dt,
    );
  }

  bool releasePlayerServe({
    required int pointerId,
    required BallState ball,
    required PlayerState player,
    required MatchState matchState,
    required ShotSystem shotSystem,
    required Vector2 racketPosition,
    required Vector2 racketDirection,
    required bool paused,
    required void Function(String text) showFeedback,
  }) {
    if (pointerId != _playerServePointerId) {
      return false;
    }
    if (ball.isInPlay || matchState.matchOver || paused) {
      clearPlayerServeCharge();
      return true;
    }

    final power = playerServeChargeFraction;
    ball
      ..x = racketPosition.x
      ..y = racketPosition.y
      ..z = 0;
    shotSystem.serve(
      ball: ball,
      hitter: player,
      racketDirection: racketDirection,
      power: power,
    );
    if (!matchState.pointInProgress) {
      matchState.startPoint();
    }
    showFeedback('SERVE ${math.max(1, (power * 100).round())}%');
    clearPlayerServeCharge();
    return true;
  }

  bool cancelPlayerServeCharge(int pointerId) {
    if (pointerId != _playerServePointerId) {
      return false;
    }
    clearPlayerServeCharge();
    return true;
  }

  void clearPlayerServeCharge() {
    _playerServePointerId = null;
    _playerServeChargeSeconds = 0;
  }

  void confirmOpponentServeReady() {
    if (opponentServePhase.value != OpponentServePhase.awaitingReady) {
      return;
    }
    _opponentServeSecondsRemaining = opponentServeCountdownSeconds;
    opponentServeCountdown.value = opponentServeCountdownSeconds.ceil();
    opponentServePhase.value = OpponentServePhase.countingDown;
  }

  void refreshOpponentServePhase(MatchState matchState) {
    if (matchState.servingSide == PlayerSide.opponent &&
        !matchState.matchOver) {
      final aimX = (_random.nextDouble() * 2 - 1) * 0.25;
      _opponentServeDirection = Vector2(aimX, 1)..normalize();
      _opponentServeSecondsRemaining = 0;
      opponentServeCountdown.value = opponentServeCountdownSeconds.ceil();
      opponentServePhase.value = OpponentServePhase.awaitingReady;
    } else {
      _opponentServeSecondsRemaining = 0;
      opponentServeCountdown.value = 0;
      opponentServePhase.value = OpponentServePhase.none;
    }
  }

  bool updateOpponentServeGate({
    required double dt,
    required BallState ball,
    required PlayerState player,
    required PlayerState opponent,
    required MatchState matchState,
    required ShotSystem shotSystem,
    required void Function(String text) showFeedback,
  }) {
    final phase = opponentServePhase.value;
    if (phase != OpponentServePhase.awaitingReady &&
        phase != OpponentServePhase.countingDown) {
      return false;
    }

    clearPlayerServeCharge();
    player.velocity.setZero();
    opponent.velocity.setZero();
    opponent.position.setValues(Court.opponentStartX, Court.opponentStartY);
    _glueBallToOpponentServeRacket(ball: ball, opponent: opponent);

    if (phase == OpponentServePhase.countingDown) {
      _opponentServeSecondsRemaining =
          math.max(0, _opponentServeSecondsRemaining - dt);
      final displayed = _opponentServeSecondsRemaining.ceil();
      if (displayed != opponentServeCountdown.value) {
        opponentServeCountdown.value = displayed;
      }
      if (_opponentServeSecondsRemaining <= 0) {
        _executeOpponentServe(
          ball: ball,
          opponent: opponent,
          matchState: matchState,
          shotSystem: shotSystem,
          showFeedback: showFeedback,
        );
      }
    }
    return true;
  }

  void glueBallToPlayerServeRacket({
    required BallState ball,
    required Vector2 racketPosition,
  }) {
    ball
      ..x = racketPosition.x
      ..y = racketPosition.y
      ..z = 0;
  }

  void _glueBallToOpponentServeRacket({
    required BallState ball,
    required PlayerState opponent,
  }) {
    final racketTip =
        opponent.position + _opponentServeDirection * Tuning.racketReach;
    ball
      ..x = racketTip.x
      ..y = racketTip.y
      ..z = 0
      ..vx = 0
      ..vy = 0
      ..vz = 0
      ..isInPlay = false;
  }

  void _executeOpponentServe({
    required BallState ball,
    required PlayerState opponent,
    required MatchState matchState,
    required ShotSystem shotSystem,
    required void Function(String text) showFeedback,
  }) {
    _glueBallToOpponentServeRacket(ball: ball, opponent: opponent);
    ball
      ..vx = _opponentServeDirection.x * Tuning.opponentServeSpeed
      ..vy = _opponentServeDirection.y * Tuning.opponentServeSpeed
      ..vz = Tuning.opponentServeLift
      ..arcGravityScale = Tuning.serveArcGravityScale
      ..lastHitBy = PlayerSide.opponent
      ..hasBouncedThisSide = false
      ..isInPlay = true;
    opponent.isSwinging = true;
    shotSystem.lastShotType = ShotType.serve;
    if (!matchState.pointInProgress) {
      matchState.startPoint();
    }
    showFeedback('SERVE');
    _opponentServeSecondsRemaining = 0;
    opponentServeCountdown.value = 0;
    opponentServePhase.value = OpponentServePhase.none;
  }
}
