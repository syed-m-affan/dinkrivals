import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/config/debug_flags.dart';

void main() {
  test('debug overlay is hidden by default for visual QA builds', () {
    expect(DebugFlags.showOverlay, isFalse);
  });
}
