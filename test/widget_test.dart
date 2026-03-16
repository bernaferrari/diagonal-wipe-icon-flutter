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
        const AnimatedDiagonalWipe.icon(
          isWiped: false,
          baseIcon: Icons.visibility,
          wipedIcon: Icons.visibility_off,
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
                AnimatedDiagonalWipe.icon(
                  isWiped: isWiped,
                  baseIcon: Icons.volume_up,
                  wipedIcon: Icons.volume_off,
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

  testWidgets('supports custom direction and animation style', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildHost(
        const AnimatedDiagonalWipe.icon(
          isWiped: true,
          baseIcon: Icons.wifi,
          wipedIcon: Icons.wifi_off,
          direction: WipeDirection.leftToRight,
          animationStyle: AnimationStyle(
            duration: Duration(milliseconds: 220),
            reverseDuration: Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            reverseCurve: Curves.linearToEaseOut,
          ),
        ),
      ),
    );

    expect(find.byType(AnimatedDiagonalWipe), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('raw constructor exposes resolved IconTheme to descendants', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildHost(
        AnimatedDiagonalWipe(
          isWiped: false,
          baseChild: Builder(
            builder: (context) {
              final IconThemeData iconTheme = IconTheme.of(context);
              return Text(
                '${iconTheme.color?.toARGB32()}:${iconTheme.size?.toStringAsFixed(0)}',
              );
            },
          ),
          wipedChild: const Icon(Icons.close),
          baseTint: Colors.green,
          wipedTint: Colors.red,
          size: 32,
        ),
      ),
    );

    expect(find.text('${Colors.green.toARGB32()}:32'), findsOneWidget);
    expect(find.byType(ClipRect), findsOneWidget);
  });

  testWidgets('raw constructor preserves explicit child styling', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildHost(
        const AnimatedDiagonalWipe(
          isWiped: false,
          baseChild: Icon(Icons.check, color: Colors.blue, size: 40),
          wipedChild: Icon(Icons.close),
          baseTint: Colors.green,
          size: 32,
        ),
      ),
    );

    final Icon icon = tester.widget<Icon>(find.byIcon(Icons.check));
    expect(icon.color, Colors.blue);
    expect(icon.size, 40);
  });

  testWidgets('raw constructor supports custom animation style', (
    WidgetTester tester,
  ) async {
    bool isWiped = false;

    await tester.pumpWidget(
      buildHost(
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedDiagonalWipe(
                  isWiped: isWiped,
                  baseChild: const Icon(Icons.play_arrow),
                  wipedChild: const Icon(Icons.pause),
                  animationStyle: const AnimationStyle(
                    duration: Duration(milliseconds: 220),
                    reverseDuration: Duration(milliseconds: 300),
                    curve: Curves.fastOutSlowIn,
                    reverseCurve: Curves.linearToEaseOut,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => isWiped = !isWiped),
                  child: const Text('toggle raw'),
                ),
              ],
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('toggle raw'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
  });

  testWidgets('AnimationStyle.noAnimation snaps immediately to the target', (
    WidgetTester tester,
  ) async {
    bool isWiped = false;

    await tester.pumpWidget(
      buildHost(
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedDiagonalWipe.icon(
                  isWiped: isWiped,
                  baseIcon: Icons.visibility,
                  wipedIcon: Icons.visibility_off,
                  animationStyle: AnimationStyle.noAnimation,
                ),
                TextButton(
                  onPressed: () => setState(() => isWiped = !isWiped),
                  child: const Text('toggle immediate'),
                ),
              ],
            );
          },
        ),
      ),
    );

    DiagonalWipeTransition transition = tester.widget<DiagonalWipeTransition>(
      find.byType(DiagonalWipeTransition),
    );
    expect(transition.progress.value, 0);

    await tester.tap(find.text('toggle immediate'));
    await tester.pump();

    transition = tester.widget<DiagonalWipeTransition>(
      find.byType(DiagonalWipeTransition),
    );
    expect(transition.progress.value, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('transition constructor renders without exceptions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildHost(
        const DiagonalWipeTransition(
          progress: AlwaysStoppedAnimation(0.5),
          baseChild: Icon(Icons.lock),
          wipedChild: Icon(Icons.lock_open),
        ),
      ),
    );

    expect(find.byType(DiagonalWipeTransition), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reverseDirection matches the requested visual reverse motion', (
    WidgetTester tester,
  ) async {
    final controller = AnimationController(vsync: tester, value: 1);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      buildHost(
        DiagonalWipeTransition(
          progress: controller,
          size: 24,
          direction: WipeDirection.topLeftToBottomRight,
          reverseDirection: WipeDirection.topRightToBottomLeft,
          baseChild: const Icon(Icons.check),
          wipedChild: const Icon(Icons.close),
        ),
      ),
    );

    controller.value = 0.75;
    await tester.pump();

    final ClipPath baseClipPath = tester.widget<ClipPath>(
      find.ancestor(
        of: find.byIcon(Icons.check),
        matching: find.byType(ClipPath),
      ),
    );

    final Path basePath = baseClipPath.clipper!.getClip(
      const Size.square(24),
    );
    expect(basePath.contains(const Offset(22, 2)), isTrue);
    expect(basePath.contains(const Offset(2, 22)), isFalse);
  });

  testWidgets('transition constructor preserves child styling', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildHost(
        const DiagonalWipeTransition(
          progress: AlwaysStoppedAnimation(0.5),
          baseChild: Icon(Icons.check, color: Colors.purple, size: 28),
          wipedChild: Icon(Icons.close, color: Colors.orange, size: 28),
          size: 28,
        ),
      ),
    );

    final Icon icon = tester.widget<Icon>(find.byIcon(Icons.check));
    expect(icon.color, Colors.purple);
    expect(icon.size, 28);
  });

  test('opposite direction flips the wipe origin', () {
    const direction = WipeDirection.topLeftToBottomRight;
    final path = buildWipeRevealPath(
      width: 24,
      height: 24,
      progress: 0.5,
      direction: direction.opposite,
    );

    expect(path.contains(const Offset(2, 2)), isFalse);
    expect(path.contains(const Offset(22, 22)), isTrue);
  });
}
