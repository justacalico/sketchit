# Sketchit

A hand-drawn style whiteboard built with Flutter, running on Android, iOS, Linux, macOS, Windows and the web.

## Features

- Rectangle, diamond, ellipse, line, arrow, freehand and text elements
- Sketchy, seeded stroke rendering with three sloppiness levels
- Selection with move, resize, rotate, layer ordering and duplication
- Undo/redo, marquee select, keyboard shortcuts
- Infinite canvas with pinch, wheel and middle-mouse pan/zoom
- Grid toggle, dark mode, stroke/fill colors, stroke styles, opacity
- PNG and JSON scene export, JSON scene import, local autosave
- Fully localized: English, 中文, Español, Français, Deutsch, 日本語, Português, Русский, العربية, 한국어

## Development

```sh
flutter pub get
flutter run          # any connected device
flutter test         # unit + widget tests
flutter build web    # web build (deployed to GitLab Pages from main)
```

## CI

GitLab CI runs `flutter analyze` and `flutter test --coverage` on every push and merge request, builds the web app to GitLab Pages on main, and produces a release APK for `v*` tags.
