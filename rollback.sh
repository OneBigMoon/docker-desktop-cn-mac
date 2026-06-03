#!/usr/bin/env bash
set -euo pipefail

BACKUP_ROOT="$HOME/.docker-desktop-cn-patcher/backups"
BACKUP_DIR="${1:-}"

if [ -z "$BACKUP_DIR" ]; then
  BACKUP_DIR="$(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort | tail -n 1 || true)"
fi

if [ -z "$BACKUP_DIR" ] || [ ! -d "$BACKUP_DIR" ]; then
  printf 'No backup found. Pass a backup directory explicitly.\n' >&2
  exit 1
fi

if [ ! -f "$BACKUP_DIR/app.asar" ] || [ ! -f "$BACKUP_DIR/Info.plist" ]; then
  printf 'Backup is incomplete: %s\n' "$BACKUP_DIR" >&2
  exit 1
fi

if [ -f "$BACKUP_DIR/app-path.txt" ]; then
  APP="$(cat "$BACKUP_DIR/app-path.txt")"
else
  APP="/Applications/Docker.app"
fi

if [ ! -d "$APP" ]; then
  printf 'Docker app not found: %s\n' "$APP" >&2
  exit 1
fi

resolve_bundle_paths() {
  local app_root=""
  if [ -f "$APP/Contents/MacOS/Docker Desktop.app/Contents/Resources/app.asar" ]; then
    app_root="$APP/Contents/MacOS/Docker Desktop.app"
  elif [ -f "$APP/Contents/Resources/app.asar" ]; then
    app_root="$APP"
  else
    local asar_path
    asar_path="$(find "$APP" -type f -path '*/Contents/Resources/app.asar' | sort | head -n 1 || true)"
    if [ -n "$asar_path" ]; then
      app_root="$(dirname "$(dirname "$(dirname "$asar_path")")")"
    fi
  fi

  if [ -z "$app_root" ]; then
    printf 'Could not locate app.asar under: %s\n' "$APP" >&2
    exit 1
  fi

  INNER="$app_root"
  INNER_INFO="$INNER/Contents/Info.plist"
  ASAR="$INNER/Contents/Resources/app.asar"
}

resolve_bundle_paths

osascript -e 'tell application "Docker Desktop" to quit' >/dev/null 2>&1 || true
pkill -x "Docker Desktop" >/dev/null 2>&1 || true
sleep 2

cp "$BACKUP_DIR/app.asar" "$ASAR"
cp "$BACKUP_DIR/Info.plist" "$INNER_INFO"
xattr -cr "$APP"
open -a "$APP"

printf 'Rolled back using backup: %s\n' "$BACKUP_DIR"
