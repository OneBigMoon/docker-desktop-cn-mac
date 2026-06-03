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

APP="$(cat "$BACKUP_DIR/app-path.txt")"
INNER="$APP/Contents/MacOS/Docker Desktop.app"
INNER_INFO="$INNER/Contents/Info.plist"
ASAR="$INNER/Contents/Resources/app.asar"

if [ ! -f "$BACKUP_DIR/app.asar" ] || [ ! -f "$BACKUP_DIR/Info.plist" ]; then
  printf 'Backup is incomplete: %s\n' "$BACKUP_DIR" >&2
  exit 1
fi

osascript -e 'tell application "Docker Desktop" to quit' >/dev/null 2>&1 || true
pkill -x "Docker Desktop" >/dev/null 2>&1 || true
sleep 2

cp "$BACKUP_DIR/app.asar" "$ASAR"
cp "$BACKUP_DIR/Info.plist" "$INNER_INFO"
xattr -cr "$APP"
open -a "$APP"

printf 'Rolled back using backup: %s\n' "$BACKUP_DIR"

