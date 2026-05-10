import '../models/shot_type.dart';

class InputSystem {
  double movementX = 0;
  double movementY = 0;

  final List<ShotType> _queuedShots = <ShotType>[];

  bool get hasMovementInput => movementX != 0 || movementY != 0;

  void setMovement(double x, double y) {
    movementX = x;
    movementY = y;
  }

  void clearMovement() {
    movementX = 0;
    movementY = 0;
  }

  void queueShot(ShotType shotType) {
    _queuedShots.add(shotType);
  }

  List<ShotType> drainShots() {
    final shots = List<ShotType>.of(_queuedShots);
    _queuedShots.clear();
    return shots;
  }
}
