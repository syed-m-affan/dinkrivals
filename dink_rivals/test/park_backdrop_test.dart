import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/config/environment_layout.dart';
import 'package:dink_rivals/widgets/park_backdrop.dart';

void main() {
  testWidgets('park backdrop uses current projection environment asset',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ParkBackdrop(child: SizedBox.shrink()),
      ),
    );

    final decoratedBox = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(ParkBackdrop),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = decoratedBox.decoration as BoxDecoration;
    final image = decoration.image!.image as AssetImage;

    expect(
      image.assetName,
      'assets/images/${EnvironmentLayout.projectionEnvironmentAsset}',
    );
    expect(image.assetName, isNot(contains('park_background_overhaul')));
  });
}
