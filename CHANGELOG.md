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
