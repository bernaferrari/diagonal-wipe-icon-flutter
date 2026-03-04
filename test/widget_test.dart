import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diagonal_wipe_icon_flutter/main.dart';
import 'package:diagonal_wipe_icon_flutter/curve_safety.dart';
import 'package:diagonal_wipe_icon_flutter/demo_catalog.dart';
import 'package:diagonal_wipe_icon_flutter/material_symbol_assets.dart';
import 'package:diagonal_wipe_icon_flutter/src/material_symbol_name.dart';

void main() {
  test('Safe curve wrapper clamps broken endpoints', () {
    final wrapper = withSafeCurveEndpoints(
      const _BrokenCurve(),
    );
    expect(wrapper.transform(0.0), 0.0);
    expect(wrapper.transform(1.0), 1.0);
    expect(CurveTween(curve: wrapper).transform(0.0), 0.0);
    expect(CurveTween(curve: wrapper).transform(1.0), 1.0);
  });

  test('Material symbol catalog resolves all icon names', () {
    final List<String> missing = [];
    final IconData fallbackIcon = materialSymbolIconData(
      const MaterialSymbolName('AutoAwesome'),
    );

    void checkSymbol(MaterialSymbolName name, String fallbackLabel) {
      final IconData resolved = materialSymbolIconData(name);
      if (resolved == fallbackIcon) {
        missing.add(fallbackLabel);
      }
    }

    void checkCatalog(MaterialWipeIconPair pair) {
      checkSymbol(pair.enabledIcon, pair.label);
      checkSymbol(pair.disabledIcon, '${pair.label} (off)');

      if (pair.enabledCodeIcon != null) {
        checkSymbol(pair.enabledCodeIcon!, '${pair.label} (code)');
      }
      if (pair.disabledCodeIcon != null) {
        checkSymbol(pair.disabledCodeIcon!, '${pair.label} (code off)');
      }

      if (pair.enabledCodeIconName != null) {
        checkSymbol(MaterialSymbolName(pair.enabledCodeIconName!),
            '${pair.label} (code name)');
      }
      if (pair.disabledCodeIconName != null) {
        checkSymbol(MaterialSymbolName(pair.disabledCodeIconName!),
            '${pair.label} (code name off)');
      }
    }

    for (final pair in coreMaterialWipeIconCatalog) {
      checkCatalog(pair);
    }
    for (final pair in knownProblemsMaterialWipeIconCatalog) {
      checkCatalog(pair);
    }

    expect(
      missing,
      isEmpty,
      reason: 'Unresolved symbols mapped to fallback: ${missing.join(', ')}',
    );
  });

  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const DiagonalWipeIconFlutterApp());
    expect(find.text('Diagonal Wipe Icons'), findsOneWidget);
  });

  testWidgets('How it works button opens and closes dialog',
      (WidgetTester tester) async {
    await tester.pumpWidget(const DiagonalWipeIconFlutterApp());

    for (var frame = 0; frame < 20; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    final howItWorksButton = find.byKey(const ValueKey('how-it-works-button'));
    expect(howItWorksButton, findsOneWidget);

    await tester.tap(howItWorksButton);
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.text('How it works'), findsAtLeastNWidgets(2));
    expect(find.text('Close'), findsOneWidget);

    final closeButton = find.text('Close');
    await tester.scrollUntilVisible(
      closeButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.tap(closeButton);
    await tester.pump(const Duration(milliseconds: 80));

    expect(closeButton, findsNothing);
  });
}

class _BrokenCurve extends Curve {
  const _BrokenCurve();

  @override
  double transformInternal(double t) {
    if (t <= 0.0) return 0.25;
    if (t >= 1.0) return 2.75;
    return t;
  }
}
