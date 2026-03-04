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

  final enabledSnippet = "Icon($enabledIcon, size: 120, color: color)";
  final disabledSnippet = "Icon($disabledIcon, size: 120, color: color)";

  return '''
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:diagonal_wipe_icon/diagonal_wipe_icon.dart';

bool isWiped = false;

DiagonalWipeIcon(
  isWiped: isWiped,
  size: 120,
  baseIcon: (size, color) => $enabledSnippet,
  wipedIcon: (size, color) => $disabledSnippet,
  baseTint: Theme.of(context).colorScheme.primary,
  wipedTint: Theme.of(context).colorScheme.secondary,
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
