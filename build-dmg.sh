#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="$ROOT/dist"
OUT="$OUT_DIR/DockerDesktop-CN-Patcher-$(date +%Y%m%d).dmg"

mkdir -p "$OUT_DIR"
hdiutil create -volname "Docker Desktop CN Patcher" -srcfolder "$ROOT" -ov -format UDZO "$OUT"
open -R "$OUT"
printf 'Created: %s\n' "$OUT"

