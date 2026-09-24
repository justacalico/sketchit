#!/usr/bin/env bash
# Package a built Flutter Linux bundle as an AppImage using appimagetool.
#
# Usage: scripts/build-appimage.sh <bundle-dir> <icon-png> <output-file> [arch]
#   arch: x86_64 or arm64, defaults to uname -m
set -euo pipefail

BUNDLE_DIR="${1:?usage: build-appimage.sh <bundle-dir> <icon-png> <output-file> [arch]}"
ICON="${2:?usage: build-appimage.sh <bundle-dir> <icon-png> <output-file> [arch]}"
OUT="${3:?usage: build-appimage.sh <bundle-dir> <icon-png> <output-file> [arch]}"
ARCH="${4:-$(uname -m)}"

case "$ARCH" in
  x86_64|amd64) TOOL_ARCH=x86_64 ;;
  arm64|aarch64) TOOL_ARCH=aarch64 ;;
  *) echo "build-appimage: unsupported arch: $ARCH" >&2; exit 1 ;;
esac

if [ ! -d "$BUNDLE_DIR" ]; then
  echo "build-appimage: bundle dir not found: $BUNDLE_DIR" >&2
  exit 1
fi

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT
APPDIR="$WORKDIR/sketchit.AppDir"

mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/share/icons/hicolor/256x256/apps"
cp -a "$BUNDLE_DIR/." "$APPDIR/usr/bin/"
cp "$ICON" "$APPDIR/usr/share/icons/hicolor/256x256/apps/sketchit.png"
ln -sf usr/share/icons/hicolor/256x256/apps/sketchit.png "$APPDIR/sketchit.png"
ln -sf sketchit.png "$APPDIR/.DirIcon"

cat > "$APPDIR/sketchit.desktop" <<'EOF'
[Desktop Entry]
Name=Sketchit
Exec=sketchit
Icon=sketchit
Type=Application
Categories=Graphics;
EOF

cat > "$APPDIR/AppRun" <<'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "$0")")"
exec "$HERE/usr/bin/sketchit" "$@"
EOF
chmod +x "$APPDIR/AppRun"

curl -fsSL --retry 3 -o "$WORKDIR/appimagetool" \
  "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-$TOOL_ARCH.AppImage"
chmod +x "$WORKDIR/appimagetool"

# GitHub runners lack FUSE; extract-and-run mode avoids it.
export APPIMAGE_EXTRACT_AND_RUN=1
export ARCH="$TOOL_ARCH"
"$WORKDIR/appimagetool" "$APPDIR" "$OUT"
echo "build-appimage: -> $OUT"
