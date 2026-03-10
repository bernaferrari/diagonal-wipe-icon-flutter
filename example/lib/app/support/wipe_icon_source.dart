import 'package:flutter/material.dart';

import 'material_symbol_assets.dart';
import 'material_symbol_name.dart';

/// Base class for icon sources that can provide a widget builder for diagonal wipe icons.
///
/// This abstraction allows flexible icon sources, whether from Material Symbols,
/// custom assets, or other icon providers.
///
/// Example usage:
/// ```dart
/// final iconSource = MaterialSymbolWipeIcon(MaterialSymbolName.wifi);
/// final builder = iconSource.builder;
/// ```
@immutable
abstract class WipeIconSource {
  const WipeIconSource();

  /// Returns a builder function that creates an icon widget with the given size and color.
  SizedIconBuilder get builder;

  /// Creates a widget directly with the specified size and color.
  Widget build(double size, Color color) => builder(size, color);
}

/// A [WipeIconSource] that uses Material Symbols icons.
@immutable
class MaterialSymbolWipeIcon extends WipeIconSource {
  const MaterialSymbolWipeIcon(this.symbolName);

  final MaterialSymbolName symbolName;

  @override
  SizedIconBuilder get builder => (size, color) {
        return Icon(
          symbolName.iconData,
          size: size,
          color: color,
        );
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MaterialSymbolWipeIcon && other.symbolName == symbolName;
  }

  @override
  int get hashCode => symbolName.hashCode;

  @override
  String toString() => 'MaterialSymbolWipeIcon($symbolName)';
}

/// A [WipeIconSource] that uses a custom IconData.
@immutable
class IconDataWipeIcon extends WipeIconSource {
  const IconDataWipeIcon(this.iconData);

  final IconData iconData;

  @override
  SizedIconBuilder get builder => (size, color) {
        return Icon(
          iconData,
          size: size,
          color: color,
        );
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IconDataWipeIcon && other.iconData == iconData;
  }

  @override
  int get hashCode => iconData.hashCode;

  @override
  String toString() => 'IconDataWipeIcon($iconData)';
}

/// A [WipeIconSource] that uses a custom widget builder.
///
/// This is useful for custom SVG icons, images, or any widget-based icon.
@immutable
class CustomWipeIcon extends WipeIconSource {
  const CustomWipeIcon(this._builder);

  final SizedIconBuilder _builder;

  @override
  SizedIconBuilder get builder => _builder;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomWipeIcon && other._builder == _builder;
  }

  @override
  int get hashCode => _builder.hashCode;
}

/// Typedef for a function that builds an icon widget with a given size and color.
typedef SizedIconBuilder = Widget Function(double size, Color color);
