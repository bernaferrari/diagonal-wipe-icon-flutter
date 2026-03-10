import 'package:flutter/material.dart';

import '../demo_catalog.dart';
import 'material_symbol_assets.dart';
import 'material_symbol_name.dart';
import 'wipe_icon_source.dart';

typedef SizedIconBuilder = Widget Function(double size, Color color);

Widget materialSymbolIcon({
  required MaterialSymbolName symbolName,
  required double size,
  required Color color,
}) {
  return Icon(fallbackIconData(symbolName), size: size, color: color);
}

IconData fallbackIconData(MaterialSymbolName symbolName) {
  return materialSymbolIconData(symbolName);
}

SizedIconBuilder materialSymbolIconBuilder(MaterialSymbolName symbolName) {
  return (size, color) =>
      materialSymbolIcon(symbolName: symbolName, size: size, color: color);
}

MaterialWipeIconPair? materialSymbolPairByLabel(String label) {
  for (final section in iconSections) {
    for (final pair in section.icons) {
      if (pair.label == label) return pair;
    }
  }
  return null;
}

MaterialSymbolName enabledCodeIconName(MaterialWipeIconPair pair) {
  if (pair.enabledCodeIcon != null) return pair.enabledCodeIcon!;
  return pair.enabledIcon;
}

MaterialSymbolName disabledCodeIconName(MaterialWipeIconPair pair) {
  if (pair.disabledCodeIcon != null) return pair.disabledCodeIcon!;
  return pair.disabledIcon;
}

String buildDiagonalWipeUsageSnippet(MaterialWipeIconPair pair) {
  final enabledCode = enabledCodeIconName(pair);
  final disabledCode = disabledCodeIconName(pair);
  final enabledIcon = materialSymbolIconCode(enabledCode);
  final disabledIcon = materialSymbolIconCode(disabledCode);

  return '''
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:diagonal_wipe_icon/diagonal_wipe_icon.dart';

bool isWiped = false;

// Implicit animation
AnimatedDiagonalWipeIcon(
  isWiped: isWiped,
  size: 120,
  baseIcon: $enabledIcon,
  wipedIcon: $disabledIcon,
  baseTint: Theme.of(context).colorScheme.primary,
  wipedTint: Theme.of(context).colorScheme.secondary,
);

// Explicit animation with an existing Animation<double>
DiagonalWipeTransition(
  progress: controller,
  size: 120,
  baseChild: const Icon($enabledIcon),
  wipedChild: const Icon($disabledIcon),
);
''';
}

/// Creates a [WipeIconSource] from a [MaterialSymbolName].
WipeIconSource materialSymbolWipeIcon(MaterialSymbolName symbolName) {
  return MaterialSymbolWipeIcon(symbolName);
}

/// Creates a pair of [WipeIconSource]s for a [MaterialWipeIconPair].
({WipeIconSource base, WipeIconSource wiped}) wipeIconSourcesForPair(
  MaterialWipeIconPair pair,
) {
  return (
    base: MaterialSymbolWipeIcon(pair.enabledIcon),
    wiped: MaterialSymbolWipeIcon(pair.disabledIcon),
  );
}
