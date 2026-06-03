#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="$ROOT/dist"
OUT="$OUT_DIR/DockerDesktop-CN-Patcher-$(date +%Y%m%d).dmg"
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/docker-cn-dmg.XXXXXX")"
cleanup() { rm -rf "$STAGE"; }
trap cleanup EXIT

"$ROOT/build-app.sh"
"$ROOT/build-pkg.sh"
mkdir -p "$OUT_DIR"
cp -R "$ROOT/build/DockerCN-Patcher.app" "$STAGE/DockerCN-Patcher.app"
cp "$ROOT"/dist/DockerDesktop-CN-Patcher-*.pkg "$STAGE/"
cp "$ROOT/README_CN.md" "$STAGE/使用说明.txt"
ln -s /Applications "$STAGE/Applications"
hdiutil create -volname "Docker Desktop CN Patcher" -srcfolder "$STAGE" -ov -format UDZO "$OUT"
open -R "$OUT"
printf 'Created: %s\n' "$OUT"
