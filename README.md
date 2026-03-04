# diagonal_wipe_icon

Animated icon transitions for Flutter using a diagonal, horizontal, or vertical wipe mask.

`diagonal_wipe_icon` blends two icon widgets with an angled reveal, similar to the icon transitions used in SF Symbols and system UI.

## Features

- Works with any two icon widgets
- Supports 8 wipe directions
- Includes motion presets for common interaction styles
- Exposes full control over durations, curves, spring parameters, and seam overlap
- Respects the platform "reduce motion" accessibility setting
- Supports an optional semantics label

## Installation

You can install the widget in whichever way fits your project.

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  diagonal_wipe_icon: ^0.1.0
```

Or run:

```bash
flutter pub add diagonal_wipe_icon
```

Or fetch the single source file directly:

```bash
curl -L https://raw.githubusercontent.com/bernaferrari/diagonal-wipe-icon/<branch-or-tag>/diagonal-wipe-icon-flutter/lib/diagonal_wipe_icon.dart -o diagonal_wipe_icon.dart
```

Or copy [`lib/diagonal_wipe_icon.dart`](lib/diagonal_wipe_icon.dart) into your project.

## Usage

```dart
import 'package:diagonal_wipe_icon/diagonal_wipe_icon.dart';

DiagonalWipeIcon.fromMotion(
  isWiped: isMuted,
  baseIcon: (size, color) => Icon(Icons.volume_up, size: size, color: color),
  wipedIcon: (size, color) => Icon(Icons.volume_off, size: size, color: color),
  semanticsLabel: 'Mute',
  motion: const DiagonalWipeMotion.gentle(
    direction: WipeDirection.topLeftToBottomRight,
  ),
)
```

## Public API

Use `DiagonalWipeIcon.fromMotion` when you want a preset such as `gentle`, `snappy`, `spring`, or `expressive`.

Use `DiagonalWipeIcon` when you want to control the animation parameters directly.

Use `DiagonalWipeIconAtProgress` when the wipe progress is driven externally, for example from your own animation controller or scroll position.

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

## Example App

A complete showcase app is included in [`example/`](example), with interactive controls for direction, timing, spring behavior, and icon pairs.

Run it with:

```bash
cd example
flutter pub get
flutter run -d chrome
```

See [`example/lib/main.dart`](example/lib/main.dart) for the full demo.

## Repository

Source, issue tracker, and the Compose counterpart live in the main repository:

https://github.com/bernaferrari/diagonal-wipe-icon

## License

MIT
