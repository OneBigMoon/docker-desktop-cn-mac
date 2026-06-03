#!/usr/bin/env bash
set -euo pipefail

APP="/Applications/Docker.app"
PATCH_ROOT="$(cd "$(dirname "$0")" && pwd)"
PATCH_JS="$PATCH_ROOT/assets/cn-patch.js"
MANIFEST="$PATCH_ROOT/manifest.json"
BACKUP_ROOT="$HOME/.docker-desktop-cn-patcher/backups"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$STAMP"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/docker-cn-patcher.XXXXXX")"

usage() {
  printf 'Usage: %s [--app /Applications/Docker.app]\n' "$0"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --app)
      APP="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

INNER="$APP/Contents/MacOS/Docker Desktop.app"
INNER_INFO="$INNER/Contents/Info.plist"
RESOURCES="$INNER/Contents/Resources"
ASAR="$RESOURCES/app.asar"

cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

need_file() {
  if [ ! -f "$1" ]; then
    printf 'Missing required file: %s\n' "$1" >&2
    exit 1
  fi
}

need_file "$PATCH_JS"
need_file "$MANIFEST"
need_file "$INNER_INFO"
need_file "$ASAR"

VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$INNER_INFO" 2>/dev/null || true)"
if [ -z "$VERSION" ]; then
  VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist" 2>/dev/null || true)"
fi

case "$VERSION" in
  4.*)
    printf 'Detected Docker Desktop %s. Applying best-effort 4.x patch.\n' "$VERSION"
    ;;
  *)
    printf 'Detected Docker Desktop %s. This patcher is designed for 4.x and will continue in best-effort mode.\n' "${VERSION:-unknown}"
    ;;
esac

mkdir -p "$BACKUP_DIR"
cp "$ASAR" "$BACKUP_DIR/app.asar"
cp "$INNER_INFO" "$BACKUP_DIR/Info.plist"
printf '%s\n' "$APP" > "$BACKUP_DIR/app-path.txt"
printf '%s\n' "${VERSION:-unknown}" > "$BACKUP_DIR/version.txt"

osascript -e 'tell application "Docker Desktop" to quit' >/dev/null 2>&1 || true
pkill -x "Docker Desktop" >/dev/null 2>&1 || true
sleep 2

npx --yes @electron/asar extract "$ASAR" "$WORK_DIR/app"

HTML="$WORK_DIR/app/build/desktop-ui-build/index.html"
ASSETS_DIR="$WORK_DIR/app/build/desktop-ui-build/assets"
TARGET_JS="$ASSETS_DIR/cn-patch.js"
ENTRY="$WORK_DIR/app/build/entry-cli.main.js"

need_file "$HTML"
mkdir -p "$ASSETS_DIR"
cp "$PATCH_JS" "$TARGET_JS"

if ! /usr/bin/grep -q 'assets/cn-patch.js' "$HTML"; then
  perl -0pi -e 's#(<script type="module" crossorigin src="/assets/[^"]+\\.js"></script>)#$1\n    <script type="module" crossorigin src="/assets/cn-patch.js"></script>#s' "$HTML"
fi

if [ -f "$ENTRY" ]; then
  perl -0pi -e 's/label:"变基"/label:"编辑"/g; s/label:\x27变基\x27/label:\x27编辑\x27/g' "$ENTRY"
fi

npx --yes @electron/asar pack "$WORK_DIR/app" "$WORK_DIR/app.asar"
cp "$WORK_DIR/app.asar" "$ASAR"

HASH="$(shasum -a 256 "$ASAR" | awk '{print $1}')"
if /usr/libexec/PlistBuddy -c 'Print :ElectronAsarIntegrity:Resources/app.asar:hash' "$INNER_INFO" >/dev/null 2>&1; then
  /usr/libexec/PlistBuddy -c "Set :ElectronAsarIntegrity:Resources/app.asar:hash $HASH" "$INNER_INFO"
fi

xattr -cr "$APP"
open -a "$APP"

printf 'Patch applied. Backup: %s\n' "$BACKUP_DIR"

