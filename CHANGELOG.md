## 0.3.0

- Require Flutter 3.50+ and Dart 3.14+ (`sdk: ^3.14.0`, `flutter: '>=3.50.0'`).
- Migrate library imports to pure `package:flutter/widgets.dart` (removing `flutter/material.dart` from the library surface) and use Dart private named initializing formals.
- Migrate `test/` and `example/` to standalone `package:material_ui/material_ui.dart` (`^1.11.0`), `flutter_lints` `^6.0.0`, and Flutter 3.50 Wasm compatibility.

## 0.2.1

- Adds `reverseDirection` to `AnimatedDiagonalWipe` and `DiagonalWipeTransition`.
- Reverse wipes now treat `reverseDirection` as the visual reverse motion. When omitted, it defaults to `direction.opposite`.
- Keeps `reverseDirection` optional so callers can preserve or customize reverse motion explicitly.

## 0.1.1

- Initial public release.
- Adds `AnimatedDiagonalWipe` for implicit icon-state animation.
- Adds `DiagonalWipeTransition` for explicit controller-driven animation.
- Uses Flutter `AnimationStyle` for implicit timing and easing customization.
- Supports diagonal and axis-aligned wipe directions.
- Includes an `example/` app demonstrating usage patterns.
