import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/components/ball_component.dart';

void main() {
  test('ball visual radius preserves prior height scale curve', () {
    expect(BallComponent.visualRadiusFor(0, 1), closeTo(4.2, 0.0001));
    expect(BallComponent.visualRadiusFor(100, 1), closeTo(8.2, 0.0001));
    expect(BallComponent.visualRadiusFor(150, 0.5), closeTo(4.1, 0.0001));
  });
}
