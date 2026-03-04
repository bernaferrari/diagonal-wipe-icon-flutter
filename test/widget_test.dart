import 'package:diagonal_wipe_icon/diagonal_wipe_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildHost(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  testWidgets('renders with semantics label', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildHost(
        DiagonalWipeIcon.fromMotion(
          isWiped: false,
          baseIcon: (size, color) =>
              Icon(Icons.visibility, size: size, color: color),
          wipedIcon: (size, color) =>
              Icon(Icons.visibility_off, size: size, color: color),
          semanticsLabel: 'Visibility',
        ),
      ),
    );

    expect(find.bySemanticsLabel('Visibility'), findsOneWidget);
  });

  testWidgets('animates when state changes', (WidgetTester tester) async {
    bool isWiped = false;

    await tester.pumpWidget(
      buildHost(
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DiagonalWipeIcon.fromMotion(
                  isWiped: isWiped,
                  baseIcon: (size, color) =>
                      Icon(Icons.volume_up, size: size, color: color),
                  wipedIcon: (size, color) =>
                      Icon(Icons.volume_off, size: size, color: color),
                  semanticsLabel: 'Mute',
                ),
                TextButton(
                  onPressed: () => setState(() => isWiped = !isWiped),
                  child: const Text('toggle'),
                ),
              ],
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('toggle'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    expect(tester.takeException(), isNull);
  });

  testWidgets('supports custom direction motion', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildHost(
        DiagonalWipeIcon.fromMotion(
          isWiped: true,
          baseIcon: (size, color) => Icon(Icons.wifi, size: size, color: color),
          wipedIcon: (size, color) =>
              Icon(Icons.wifi_off, size: size, color: color),
          motion: const DiagonalWipeMotion.gentle(
            direction: WipeDirection.leftToRight,
          ),
        ),
      ),
    );

    expect(find.byType(DiagonalWipeIcon), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
