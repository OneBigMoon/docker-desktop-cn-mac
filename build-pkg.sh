#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
"$ROOT/build-app.sh"
APP="$ROOT/build/DockerCN-Patcher.app"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist" 2>/dev/null || echo '0.4.1')"
OUT_DIR="$ROOT/dist"
PKG_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/docker-cn-pkgroot.XXXXXX")"
SCRIPTS_DIR="$(mktemp -d "${TMPDIR:-/tmp}/docker-cn-pkgscripts.XXXXXX")"
COMPONENT_PLIST="$(mktemp "${TMPDIR:-/tmp}/docker-cn-components.XXXXXX.plist")"
OUT="$OUT_DIR/DockerDesktop-CN-Patcher-${VERSION}.pkg"

cleanup() {
  rm -rf "$PKG_ROOT" "$SCRIPTS_DIR" "$COMPONENT_PLIST"
}
trap cleanup EXIT

mkdir -p "$OUT_DIR"
rm -f "$OUT_DIR"/DockerDesktop-CN-Patcher-*.pkg
mkdir -p "$PKG_ROOT/Applications"
mkdir -p "$PKG_ROOT/Library/Application Support/DockerCN-Patcher/assets"
mkdir -p "$PKG_ROOT/Library/Application Support/DockerCN-Patcher/scripts"

cp -R "$APP" "$PKG_ROOT/Applications/DockerCN-Patcher.app"
cp "$ROOT/install.sh" "$PKG_ROOT/Library/Application Support/DockerCN-Patcher/install.sh"
cp "$ROOT/rollback.sh" "$PKG_ROOT/Library/Application Support/DockerCN-Patcher/rollback.sh"
cp "$ROOT/manifest.json" "$PKG_ROOT/Library/Application Support/DockerCN-Patcher/manifest.json"
cp "$ROOT/assets/cn-patch.js" "$PKG_ROOT/Library/Application Support/DockerCN-Patcher/assets/cn-patch.js"
cp "$ROOT/scripts/asar.py" "$PKG_ROOT/Library/Application Support/DockerCN-Patcher/scripts/asar.py"
chmod +x "$PKG_ROOT/Library/Application Support/DockerCN-Patcher/install.sh" \
  "$PKG_ROOT/Library/Application Support/DockerCN-Patcher/rollback.sh" \
  "$PKG_ROOT/Library/Application Support/DockerCN-Patcher/scripts/asar.py"

cat > "$COMPONENT_PLIST" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
  <dict>
    <key>BundleHasStrictIdentifier</key>
    <true/>
    <key>BundleIsRelocatable</key>
    <false/>
    <key>BundleIsVersionChecked</key>
    <false/>
    <key>BundleOverwriteAction</key>
    <string>upgrade</string>
    <key>RootRelativeBundlePath</key>
    <string>Applications/DockerCN-Patcher.app</string>
  </dict>
</array>
</plist>
PLIST

cat > "$SCRIPTS_DIR/postinstall" <<'POSTINSTALL'
#!/usr/bin/env bash
set -euo pipefail

LOG="/var/log/docker-cn-patcher-install.log"
PATCHER_DIR="/Library/Application Support/DockerCN-Patcher"
INSTALL="$PATCHER_DIR/install.sh"
APP="/Applications/Docker.app"

echo "==== DockerCN Patcher postinstall $(date) ====" >> "$LOG"

if [ ! -x "$INSTALL" ]; then
  echo "Missing installer script: $INSTALL" >> "$LOG"
  exit 1
fi

if [ ! -d "$APP" ]; then
  echo "Docker.app not found: $APP" >> "$LOG"
  exit 1
fi

DOCKER_CN_PATCHER_PROGRESS=1 "$INSTALL" --app "$APP" >> "$LOG" 2>&1

echo "==== DockerCN Patcher postinstall done $(date) ====" >> "$LOG"
exit 0
POSTINSTALL
chmod +x "$SCRIPTS_DIR/postinstall"

pkgbuild \
  --root "$PKG_ROOT" \
  --scripts "$SCRIPTS_DIR" \
  --component-plist "$COMPONENT_PLIST" \
  --identifier "com.onebigmoon.docker-cn-patcher" \
  --version "$VERSION" \
  --install-location "/" \
  "$OUT"

printf 'Created: %s\n' "$OUT"
