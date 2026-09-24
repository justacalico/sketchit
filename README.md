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

## Install

Prebuilt binaries for every platform are attached to each [GitLab release](https://gitlab.com/HttpAnimations/sketchit/-/releases): Android APK/AAB, Linux (tar.gz, zip, deb, rpm, AppImage for x86_64 and arm64), Windows zips, macOS dmg/zip, an unsigned iOS ipa, and the web build.

### AltStore (iOS)

Add the AltStore source to install and update Sketchit on iOS:

```
https://sketchit-546a9a.gitlab.io/altstore/apps.json
```

The source regenerates itself after every release and always points at the newest signed-on-device ipa.

## CI

GitLab is the source of truth; builds run on GitHub Actions and the release binaries are synced back to GitLab so they never expire. Pushes to `main` mirror to GitHub, run analyze + tests and the full build matrix, and publish a `nightly` release. `v*` tags (cut automatically by cocogitto) produce the versioned release on both hosts; the sync pipeline then updates the AltStore source and redeploys GitLab Pages.
