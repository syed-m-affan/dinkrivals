class InputSystem {
  double movementX = 0;
  double movementY = 0;
  double racketAngle = 0;
  double racketAngularVelocity = 0;

  double _previousRacketAngle = 0;

  bool get hasMovementInput => movementX != 0 || movementY != 0;

  void setMovement(double x, double y) {
    movementX = x;
    movementY = y;
  }

  void clearMovement() {
    movementX = 0;
    movementY = 0;
  }

  void updateRacket(double dt) {
    if (dt <= 0) {
      racketAngularVelocity = 0;
      return;
    }
    racketAngularVelocity = (racketAngle - _previousRacketAngle) / dt;
    _previousRacketAngle = racketAngle;
  }

  void swingRacket(double deltaRadians, double maxAngle) {
    racketAngle =
        (racketAngle + deltaRadians).clamp(-maxAngle, maxAngle).toDouble();
  }

  void resetRacket() {
    racketAngle = 0;
    racketAngularVelocity = 0;
    _previousRacketAngle = 0;
  }
}
