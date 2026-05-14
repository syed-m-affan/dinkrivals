class Court {
  static const double width = 220.0;
  static const double length = 480.0;
  static const double feetToUnits = length / 44.0;
  static const double netY = 240.0;

  static const double left = 0.0;
  static const double right = width;
  static const double top = 0.0;
  static const double bottom = length;

  static const double kitchenDepth = 7.0 * feetToUnits;
  static const double netHeight = 3.5 * feetToUnits;
  static const double netPostHeight = 4.0 * feetToUnits;

  static const double playerKitchenTopY = netY;
  static const double playerKitchenBottomY = netY + kitchenDepth;
  static const double opponentKitchenTopY = netY - kitchenDepth;
  static const double opponentKitchenBottomY = netY;

  static const double playerStartX = 110.0;
  static const double playerStartY = 400.0;
  static const double opponentStartX = 110.0;
  static const double opponentStartY = 80.0;

  static const double ballServeX = 110.0;
  static const double ballServeY = 358.0;
}
