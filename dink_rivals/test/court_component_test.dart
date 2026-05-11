import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/components/court_component.dart';

void main() {
  test('generated court surface texture asset is checked in', () {
    expect(
      CourtComponent.surfaceTextureAsset,
      'court/court_surface_texture_generated.png',
    );
    expect(
      File('assets/images/${CourtComponent.surfaceTextureAsset}').existsSync(),
      isTrue,
    );
  });
}
