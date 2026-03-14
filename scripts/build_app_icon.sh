#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ICONSET_DIR="$ROOT_DIR/Resources/AppIcon.iconset"
TMP_TIFF_DIR="$ROOT_DIR/Resources/.appicon-tiff"
COMBINED_TIFF="$ROOT_DIR/Resources/AppIcon.tiff"
ICON_FILE="$ROOT_DIR/Resources/AppIcon.icns"
MASTER_PNG="$ROOT_DIR/Resources/AppIcon-1024.png"
SOURCE_PNG="${1:-}"

mkdir -p "$ROOT_DIR/Resources"

if [[ -n "$SOURCE_PNG" ]]; then
  cp "$SOURCE_PNG" "$MASTER_PNG"
fi

if [[ ! -f "$MASTER_PNG" ]]; then
  echo "Missing master icon PNG at $MASTER_PNG" >&2
  echo "Usage: $0 /path/to/1024x1024-icon.png" >&2
  exit 1
fi

rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

for size in 16 32 128 256 512; do
  sips -z "$size" "$size" "$MASTER_PNG" --out "$ICONSET_DIR/icon_${size}x${size}.png" >/dev/null
  retina_size=$((size * 2))
  sips -z "$retina_size" "$retina_size" "$MASTER_PNG" --out "$ICONSET_DIR/icon_${size}x${size}@2x.png" >/dev/null
done

rm -rf "$TMP_TIFF_DIR"
mkdir -p "$TMP_TIFF_DIR"

for png in "$ICONSET_DIR"/*.png; do
  tiff="$TMP_TIFF_DIR/$(basename "${png%.png}.tiff")"
  sips -s format tiff "$png" --out "$tiff" >/dev/null
done

tiffutil -cat "$TMP_TIFF_DIR"/*.tiff -out "$COMBINED_TIFF"
tiff2icns "$COMBINED_TIFF" "$ICON_FILE"

rm -rf "$TMP_TIFF_DIR" "$COMBINED_TIFF"

echo "$ICON_FILE"
