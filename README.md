<div align="center">

# Diagonal Wipe Icon for Flutter

<a href="https://bernaferrari.github.io/diagonal-wipe-icon-flutter/">
  <img src="https://raw.githubusercontent.com/bernaferrari/diagonal-wipe-icon-flutter/main/assets/animated-icons.webp" width="680" alt="Diagonal wipe icon animation in action">
</a>


<a href="https://bernaferrari.github.io/diagonal-wipe-icon-flutter/">
  <img src="https://raw.githubusercontent.com/bernaferrari/diagonal-wipe-icon-flutter/main/assets/preview.png" width="680" alt="Diagonal wipe icon static preview">
</a>

**[🚀 Live Demo](https://bernaferrari.github.io/diagonal-wipe-icon-flutter/)**


</div>

## 📖 What Is This?

Apple's **SF Symbols** makes it easy to add wipe icon transitions to iOS apps. Flutter does not ship that interaction out of the box, making it tempting to skip the animation entirely.

**Diagonal Wipe Icon** bridges this gap. It provides a polished component that blends two icon states with a moving mask, supporting 8 different wipe directions. Perfect for:
- 🎛️ **Toggle controls** (`mute`, `favorite`, `visible`)
- ⚙️ **Settings screens** with stateful icons
- ✨ **Anywhere** you want polished micro-interactions

**Accessible & lightweight. Zero dependencies.**

## 🚀 Quick Start

[![pub package](https://img.shields.io/pub/v/diagonal_wipe_icon.svg)](https://pub.dev/packages/diagonal_wipe_icon)

Add the package via terminal:
```bash
flutter pub add diagonal_wipe_icon
```

Or add it manually to your `pubspec.yaml`:
```yaml
dependencies:
  diagonal_wipe_icon: ^0.1.0
```

Then, use it anywhere you would typically place an `Icon`, such as inside an `IconButton` or a `GestureDetector`:

```dart
import 'package:diagonal_wipe_icon/diagonal_wipe_icon.dart';

IconButton(
  onPressed: () => setState(() => isFavorite = !isFavorite),
  icon: AnimatedDiagonalWipeIcon(
    isWiped: isFavorite,
    baseIcon: Icons.favorite_border,
    wipedIcon: Icons.favorite,
    semanticsLabel: 'Favorite Toggle',
  ),
);
```

## 🧰 Choose The Right API

| If you have... | Use |
| --- | --- |
| Two `IconData` values | `AnimatedDiagonalWipeIcon(...)` |
| Two widgets | `AnimatedDiagonalWipeIcon.raw(...)` |
| An `Animation<double>` and two widgets | `DiagonalWipeTransition(...)` |

### Key Properties

| Property | Description |
| --- | --- |
| `isWiped` | Which icon is fully visible (true/false state). |
| `baseIcon` / `wipedIcon` | The two icons to transition between. |
| `baseTint` / `wipedTint` | Optional colors. Inherits from `IconTheme` if null. |
| `size` | Optional size. Inherits from `IconTheme` if null. |
| `direction` | Defaults to `bottomLeftToTopRight`. |
| `animationStyle` | Timing constraints, curves, or disables animation entirely. |

## 🎨 Customization

`AnimatedDiagonalWipeIcon` animates automatically when `isWiped` changes. You can deeply customize the transition timing and ease using `animationStyle` or tweak the exact direction and colors:

```dart
AnimatedDiagonalWipeIcon(
  // State and Icons
  isWiped: isMuted,
  baseIcon: Icons.volume_up,
  wipedIcon: Icons.volume_off,
  
  // Customization
  baseTint: Colors.teal,
  direction: WipeDirection.bottomLeftToTopRight, // 8 directions supported
  
  // Motion Presets
  animationStyle: const AnimationStyle(
    duration: Duration(milliseconds: 220),
    curve: Curves.fastOutSlowIn,
  ),
)
```

<div align="center">

<a href="https://bernaferrari.github.io/diagonal-wipe-icon-flutter/">
  <img src="https://raw.githubusercontent.com/bernaferrari/diagonal-wipe-icon-flutter/main/assets/how-it-works-mini.webp" width="680" alt="Diagonal wipe mask animation in action">
</a>

<a href="https://bernaferrari.github.io/diagonal-wipe-icon-flutter/">
  <img src="https://raw.githubusercontent.com/bernaferrari/diagonal-wipe-icon-flutter/main/assets/how-it-works.png" width="680" alt="Diagram showing the wipe mask clipping one layer over another">
</a>

</div>

## ⚡ Performance & Under The Hood

The effect works by revealing one layer while clipping the other across a shared square box.

| Scenario | Performance |
|----------|-------------|
| **At Rest** (`isWiped` settled) | Same as rendering a single static layer. |
| **During Transition** | Two clipped layers plus path updates. |
| **Normal Usage** | Flawless and smooth on modern devices. |

- ✅ Settled states bypass clipping overhead
- ✅ Respects system reduce-motion preferences by jumping to final state

## ❓ FAQ

- **Why use this instead of `AnimatedSwitcher`?**  
  Use it when you want an icon transition to feel like a state change. If a simple cross-fade is enough, `AnimatedSwitcher` is a great fit.
- **Can I use custom widgets?**  
  Yes! Use `AnimatedDiagonalWipeIcon.raw(...)` for arbitrary widgets, like a `CircularProgressIndicator`.
- **Run the Demo Locally:**
  ```bash
  cd example
  flutter run -d chrome
  ```

## 🌍 Also Available For Compose

A Compose Multiplatform version lives in the companion repository:

- [bernaferrari/diagonal-wipe-icon](https://github.com/bernaferrari/diagonal-wipe-icon)
