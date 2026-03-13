#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_BUNDLE="$ROOT_DIR/dist/Clipiary.app"

"$ROOT_DIR/scripts/build_app.sh" "${1:-debug}"
open "$APP_BUNDLE"
