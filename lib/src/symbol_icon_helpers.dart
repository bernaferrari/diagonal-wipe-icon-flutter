import 'package:flutter/material.dart';

import '../demo_catalog.dart';
import '../material_symbol_assets.dart';
import 'material_symbol_name.dart';

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

String _toPascalCase(String label) {
  final parts = label
      .replaceAll(RegExp(r'[^A-Za-z0-9 ]'), ' ')
      .trim()
      .split(RegExp(r'\s+'))
      .where((value) => value.isNotEmpty)
      .toList();

  if (parts.isEmpty) return 'Icon';

  return parts
      .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
      .join();
}

MaterialSymbolName enabledCodeIconName(MaterialWipeIconPair pair) {
  if (pair.enabledCodeIcon != null) return pair.enabledCodeIcon!;

  if (pair.label.startsWith('No ')) {
    return MaterialSymbolName.of(pair.label.substring(3));
  }

  if (pair.label.endsWith(' Off')) {
    return MaterialSymbolName.of(
      pair.label.substring(0, pair.label.length - 4),
    );
  }

  if (pair.label.endsWith(' Disabled')) {
    return MaterialSymbolName.of(
      pair.label.substring(0, pair.label.length - 9),
    );
  }

  return MaterialSymbolName.of(_toPascalCase(pair.label));
}

MaterialSymbolName disabledCodeIconName(MaterialWipeIconPair pair) {
  if (pair.disabledCodeIcon != null) return pair.disabledCodeIcon!;

  if (pair.label.startsWith('No ')) {
    return MaterialSymbolName.of('No${_toPascalCase(pair.label.substring(3))}');
  }

  if (pair.label.endsWith(' Off')) {
    return MaterialSymbolName.of(
      '${_toPascalCase(pair.label.substring(0, pair.label.length - 4))}Off',
    );
  }

  if (pair.label.endsWith(' Disabled')) {
    return MaterialSymbolName.of(
      '${_toPascalCase(pair.label.substring(0, pair.label.length - 9))}Disabled',
    );
  }

  return MaterialSymbolName.of('${_toPascalCase(pair.label)}Off');
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
import 'diagonal_wipe_icon.dart';

bool isWiped = false;

DiagonalWipeIcon(
  isWiped: isWiped,
  size: 120,
  baseIcon: (size, color) => $enabledSnippet,
  wipedIcon: (size, color) => $disabledSnippet,
  baseTint: const Color(0xFF1976D2),
  wipedTint: const Color(0xFF7C4DFF),
);
''';
}
