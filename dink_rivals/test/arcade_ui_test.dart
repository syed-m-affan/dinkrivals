import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/widgets/arcade_button.dart';
import 'package:dink_rivals/widgets/arcade_panel.dart';

void main() {
  testWidgets('arcade panel renders child content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ArcadePanel(child: Text('Panel content')),
        ),
      ),
    );

    expect(find.text('Panel content'), findsOneWidget);
  });

  testWidgets('arcade button handles taps and optional icons', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ArcadeButton(
            label: 'Quick Match',
            icon: Icons.sports_tennis,
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Quick Match'));
    await tester.pump();

    expect(tapped, isTrue);
    expect(find.byIcon(Icons.sports_tennis), findsOneWidget);
  });
}
