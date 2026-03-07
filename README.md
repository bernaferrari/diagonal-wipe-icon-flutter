<div align="center">

<img src="assets/animated-icons.webp" width="680" alt="Diagonal wipe icon animation in Flutter">

# Diagonal Wipe Icon
**SF Symbols-style icon transitions for Flutter**

One package, two clean APIs: `AnimatedDiagonalWipeIcon` for app-state toggles, and `DiagonalWipeTransition` for controller-driven animations.

<img src="assets/preview.png" width="680" alt="Diagonal wipe icon static preview in Flutter">

</div>

## What Is This?

Apple's SF Symbols makes wipe-style icon transitions feel built in. In Flutter, the same effect usually ends up as manual icon swapping, one-off clip logic, or a custom animation that gets rewritten every time the UI needs a polished toggle.

**Diagonal Wipe Icon** packages that interaction into a reusable Flutter component. It blends two icon states with a moving mask and supports diagonal, horizontal, and vertical wipe directions.

Good fits:

- toggle controls like `mute`, `favorite`, `visible`, and `enabled`
- settings rows with stateful icons
- media controls and playback affordances
- any icon swap that should feel more refined than a hard cut or cross-fade

**No runtime dependencies beyond Flutter.**

## Quick Start

```bash
flutter pub add diagonal_wipe_icon
```

Or add it manually to `pubspec.yaml`:

```yaml
dependencies:
  diagonal_wipe_icon: ^0.1.0
```

If you prefer vendoring the implementation, the core widget lives in a single file: [`lib/diagonal_wipe_icon.dart`](lib/diagonal_wipe_icon.dart). You can also fetch it directly instead of adding the package:

```bash
curl -O https://raw.githubusercontent.com/bernaferrari/diagonal-wipe-icon-flutter/main/lib/diagonal_wipe_icon.dart
```

Minimal example:

```dart
import 'package:diagonal_wipe_icon/diagonal_wipe_icon.dart';
import 'package:flutter/material.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({super.key});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => setState(() => isFavorite = !isFavorite),
      icon: AnimatedDiagonalWipeIcon(
        isWiped: isFavorite,
        baseIcon: Icons.favorite_border,
        wipedIcon: Icons.favorite,
        semanticsLabel: 'Favorite',
      ),
    );
  }
}
```

## Choose The Right API

| If you have... | Use |
| --- | --- |
| two `IconData` values and a boolean state | `AnimatedDiagonalWipeIcon(...)` |
| two already-built widgets and a boolean state | `AnimatedDiagonalWipeIcon.raw(...)` |
| an existing `Animation<double>` | `DiagonalWipeTransition(...)` |

Most apps should start with `AnimatedDiagonalWipeIcon(...)`.

## Animation Style

`AnimatedDiagonalWipeIcon` already animates by default. Use `animationStyle` only when you want different timing or easing:

```dart
AnimatedDiagonalWipeIcon(
  isWiped: isMuted,
  baseIcon: Icons.volume_up,
  wipedIcon: Icons.volume_off,
  baseTint: Colors.teal,
  wipedTint: Colors.teal,
  direction: WipeDirection.bottomLeftToTopRight,
  animationStyle: const AnimationStyle(
    duration: Duration(milliseconds: 220),
    reverseDuration: Duration(milliseconds: 300),
    curve: Curves.fastOutSlowIn,
    reverseCurve: Curves.linearToEaseOut,
  ),
)
```

If you do nothing, the widget uses its built-in default style. If you need to disable the implicit animation entirely, pass `AnimationStyle.noAnimation`.

## Raw Widgets

When your two states are already widgets, use `raw(...)`:

```dart
AnimatedDiagonalWipeIcon.raw(
  isWiped: isLoading,
  baseChild: const Icon(Icons.download),
  wipedChild: const SizedBox.square(
    dimension: 18,
    child: CircularProgressIndicator(strokeWidth: 2),
  ),
  size: 24,
  animationStyle: const AnimationStyle(
    duration: Duration(milliseconds: 220),
    reverseDuration: Duration(milliseconds: 300),
    curve: Curves.fastOutSlowIn,
    reverseCurve: Curves.linearToEaseOut,
  ),
)
```

Raw children are centered, clipped to the wipe bounds, and wrapped in an `IconTheme`. Icon-like widgets inherit the resolved size and tint automatically, while explicitly styled widgets keep their own styling.

## Transition Primitive

Use `DiagonalWipeTransition(...)` when the animation is driven elsewhere:

```dart
class PlayerIcon extends StatefulWidget {
  const PlayerIcon({super.key});

  @override
  State<PlayerIcon> createState() => _PlayerIconState();
}

class _PlayerIconState extends State<PlayerIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (controller.status == AnimationStatus.completed) {
          controller.reverse();
        } else {
          controller.forward();
        }
      },
      icon: DiagonalWipeTransition(
        progress: controller,
        baseChild: const Icon(Icons.play_arrow),
        wipedChild: const Icon(Icons.pause),
      ),
    );
  }
}
```

Use this when the wipe should follow a scroll position, gesture, or custom `AnimationController` exactly.

## Wipe Directions

Available `WipeDirection` values:

- `topLeftToBottomRight`
- `bottomRightToTopLeft`
- `topRightToBottomLeft`
- `bottomLeftToTopRight`
- `topToBottom`
- `bottomToTop`
- `leftToRight`
- `rightToLeft`

<div align="center">

<img src="assets/how-it-works-mini.webp" width="680" alt="Diagonal wipe icon animation showing how the reveal mask moves">

<img src="assets/how-it-works.png" width="680" alt="Diagram showing how one icon is clipped away while the other is revealed">

</div>

## Performance

The effect works by revealing one layer while clipping the other across a shared square box.

| Scenario | Cost |
| --- | --- |
| At rest | Equivalent to a single visible layer |
| During transition | Two clipped layers plus path updates |
| Typical usage | Smooth on modern devices for normal icon counts |

- settled states render only one layer
- animated states isolate the work in a `RepaintBoundary`
- reduce-motion accessibility settings jump directly to the final state

## FAQ

- Can I use my own widgets?  
  Yes. Use `AnimatedDiagonalWipeIcon.raw(...)` or `DiagonalWipeTransition(...)`.

- Can I drive it from my own controller?  
  Yes. Use `DiagonalWipeTransition(...)`.

- What about accessibility?  
  Pass `semanticsLabel` on `AnimatedDiagonalWipeIcon`.

- Does it work across Flutter platforms?  
  Yes. Android, iOS, web, macOS, Windows, and Linux are supported.

## Example App

The repository includes a full demo app in [`example/`](example), with controls for direction, timing, and icon pairs.

Run it locally:

```bash
cd example
flutter pub get
flutter run -d chrome
```

The main demo entry point is [`example/lib/main.dart`](example/lib/main.dart).

## Also Available For Compose

Compose Multiplatform version:

- Repository: https://github.com/bernaferrari/diagonal-wipe-icon

## License

MIT
