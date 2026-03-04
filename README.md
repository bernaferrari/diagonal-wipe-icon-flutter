# Flutter Demo

This directory contains a full Flutter port of the Compose icon wipe demo.

## Run

```bash
cd flutter
flutter pub get
flutter run -d chrome
```

### Web output

```bash
cd flutter
flutter build web
```

Open `build/web` with a static file server, or run:

```bash
flutter run -d chrome
```

Use any available device instead of `chrome` if you want to run on mobile.

## What’s Included

- `lib/main.dart`: App shell, catalog grid, dialogs, and controls.
- `lib/diagonal_wipe_icon.dart`: Core `DiagonalWipeIcon` widget and geometry helpers.
- `lib/material_symbol_assets.dart`: Asset mapping for Material symbol names.
- `lib/demo_catalog.dart`: Full icon catalog used by the demo.
- `lib/src/symbol_icon_helpers.dart`: Icon builders and snippet generator.
- `assets/`: PNG/WEBP previews used by the demo UI.

The project no longer depends on vector drawables or XML parsing in Flutter.
