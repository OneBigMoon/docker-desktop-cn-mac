#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
VERSION="$(python3 - <<'PY'
import json
from pathlib import Path
try:
    print(json.loads(Path('manifest.json').read_text()).get('version', '0.4.1'))
except Exception:
    print('0.4.1')
PY
)"
APP="$ROOT/build/DockerCN-Patcher.app"
CONTENTS_DIR="$APP/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
PATCHER_DIR="$RESOURCES_DIR/patcher"
BINARY="$MACOS_DIR/DockerCNPatcher"
SOURCE="$ROOT/src/DockerCNPatcherApp.swift"

if [ ! -f "$SOURCE" ]; then
  printf 'Missing GUI source: %s\n' "$SOURCE" >&2
  exit 1
fi

rm -rf "$APP"
mkdir -p "$MACOS_DIR" "$PATCHER_DIR/assets" "$PATCHER_DIR/scripts"

cat > "$CONTENTS_DIR/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>
  <string>DockerCN Patcher</string>
  <key>CFBundleDisplayName</key>
  <string>DockerCN Patcher</string>
  <key>CFBundleIdentifier</key>
  <string>com.onebigmoon.docker-cn-patcher</string>
  <key>CFBundleExecutable</key>
  <string>DockerCNPatcher</string>
  <key>CFBundleShortVersionString</key>
  <string>$VERSION</string>
  <key>CFBundleVersion</key>
  <string>$VERSION</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>LSMinimumSystemVersion</key>
  <string>12.0</string>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>NSSystemAdministrationUsageDescription</key>
  <string>需要管理员权限写入 Docker Desktop 应用资源，以安装或恢复汉化补丁。</string>
  <key>NSAppleEventsUsageDescription</key>
  <string>需要打开 Terminal 执行安装脚本，并在需要时请求系统管理员授权。</string>
</dict>
</plist>
PLIST

/usr/bin/swiftc "$SOURCE" -framework Cocoa -o "$BINARY"
chmod +x "$BINARY"

cp "$ROOT/install.sh" "$PATCHER_DIR/install.sh"
cp "$ROOT/rollback.sh" "$PATCHER_DIR/rollback.sh"
cp "$ROOT/manifest.json" "$PATCHER_DIR/manifest.json"
cp "$ROOT/assets/cn-patch.js" "$PATCHER_DIR/assets/cn-patch.js"
cp "$ROOT/scripts/asar.py" "$PATCHER_DIR/scripts/asar.py"
chmod +x "$PATCHER_DIR/install.sh" "$PATCHER_DIR/rollback.sh" "$PATCHER_DIR/scripts/asar.py"
xattr -cr "$APP" >/dev/null 2>&1 || true
codesign --force --deep --sign - "$APP" >/dev/null 2>&1 || true

printf 'Built app: %s\n' "$APP"
