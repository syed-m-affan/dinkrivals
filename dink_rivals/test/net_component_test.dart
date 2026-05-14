import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/components/net_component.dart';
import 'package:dink_rivals/game/config/court_constants.dart';
import 'package:dink_rivals/game/dink_rivals_game.dart';

void main() {
  test('net is taller than regulation for graybox readability', () {
    expect(Court.netHeight, greaterThan((34.0 / 12.0) * Court.feetToUnits));
    expect(Court.netPostHeight, greaterThan(Court.netHeight));
  });

  test('net sorts at court depth so near objects draw in front', () {
    final net = NetComponent(DinkRivalsGame());

    expect(net.priority, Court.netY.round());
    expect(Court.netY + 1, greaterThan(net.priority));
    expect(Court.netY - 1, lessThan(net.priority));
  });
}
