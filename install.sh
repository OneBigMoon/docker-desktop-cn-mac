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
LAUNCH_AFTER_INSTALL=1
AUTO_ROLLBACK=1
NO_RESTART=0
RESTORE_LATEST=0
RESTORE_BACKUP_DIR=""
BACKUP_READY=0
PATCH_SUCCEEDED=0
ROLLING_BACK=0

usage() {
  printf 'Usage: %s [--app /Applications/Docker.app] [--no-launch] [--no-restart] [--no-auto-rollback]\n' "$0"
  printf '       %s --restore-latest [--app /Applications/Docker.app]\n' "$0"
  printf '       %s --restore-backup <backup-folder> [--app /Applications/Docker.app]\n' "$0"
  printf '       %s --list-backups\n' "$0"
}

emit_progress() {
  if [ "${DOCKER_CN_PATCHER_PROGRESS:-0}" = "1" ]; then
    printf '::progress::%s::%s\n' "$1" "$2"
  fi
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --list-backups)
      ls -1 "$BACKUP_ROOT"
      exit 0
      ;;
    --restore-latest)
      RESTORE_LATEST=1
      shift
      ;;
    --restore-backup)
      RESTORE_BACKUP_DIR="${2:-}"
      if [ -z "$RESTORE_BACKUP_DIR" ]; then
        echo "Missing backup directory for --restore-backup" >&2
        exit 1
      fi
      shift 2
      ;;
    --app)
      APP="${2:-}"
      shift 2
      ;;
    --no-launch)
      LAUNCH_AFTER_INSTALL=0
      shift
      ;;
    --no-restart)
      NO_RESTART=1
      LAUNCH_AFTER_INSTALL=0
      shift
      ;;
    --no-auto-rollback)
      AUTO_ROLLBACK=0
      shift
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

# Docker.app nested bundle changed across versions in some releases; resolve safely.
resolve_bundle_paths() {
  local app_root

  if [ ! -d "$APP" ]; then
    printf 'Docker app not found: %s\n' "$APP" >&2
    exit 1
  fi

  if [ -f "$APP/Contents/MacOS/Docker Desktop.app/Contents/Resources/app.asar" ]; then
    app_root="$APP/Contents/MacOS/Docker Desktop.app"
  elif [ -f "$APP/Contents/Resources/app.asar" ]; then
    app_root="$APP"
  else
    app_root="$(find "$APP" -type f -path '*/Contents/Resources/app.asar' | sort | head -n 1 || true)"
    if [ -n "$app_root" ]; then
      app_root="$(dirname "$(dirname "$(dirname "$app_root")")")"
    else
      printf 'Could not locate app.asar under: %s\n' "$APP" >&2
      exit 1
    fi
  fi

  INNER="$app_root"
  INNER_INFO="$INNER/Contents/Info.plist"
  RESOURCES="$INNER/Contents/Resources"
  ASAR="$RESOURCES/app.asar"
}

resolve_bundle_paths

restore_backup() {
  local dir="$1"
  local backup_asar="$dir/app.asar"
  local backup_info="$dir/Info.plist"

  if [ -z "$dir" ]; then
    echo "No backup directory specified." >&2
    exit 1
  fi
  if [ ! -d "$dir" ]; then
    echo "Backup directory not found: $dir" >&2
    exit 1
  fi
  if [ ! -f "$backup_asar" ] || [ ! -f "$backup_info" ]; then
    echo "Backup is incomplete: $dir" >&2
    exit 1
  fi

  emit_progress 20 "关闭 Docker Desktop"
  osascript -e 'tell application "Docker Desktop" to quit' >/dev/null 2>&1 || true
  pkill -x "Docker Desktop" >/dev/null 2>&1 || true
  sleep 2
  emit_progress 30 "正在恢复备份文件"
  cp "$backup_asar" "$ASAR"
  cp "$backup_info" "$INNER_INFO"
  xattr -cr "$APP"
  emit_progress 100 "恢复完成"
  echo "Restored backup: $dir"
}

if [ "$RESTORE_LATEST" -eq 1 ] || [ -n "$RESTORE_BACKUP_DIR" ]; then
  if [ "$RESTORE_LATEST" -eq 1 ]; then
    latest="$(ls -1t "$BACKUP_ROOT" 2>/dev/null | head -n 1 || true)"
    if [ -z "$latest" ]; then
      echo "No backups found in $BACKUP_ROOT" >&2
      exit 1
    fi
    restore_backup "$BACKUP_ROOT/$latest"
    exit 0
  fi

  if [ -n "$RESTORE_BACKUP_DIR" ]; then
    restore_backup "$RESTORE_BACKUP_DIR"
    exit 0
  fi
fi

need_file() {
  local file="$1"
  if [ ! -f "$file" ]; then
    printf 'Missing required file: %s\n' "$file" >&2
    exit 1
  fi
}

cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

rollback_on_error() {
  local status="$?"
  if [ "$status" -eq 0 ]; then
    return 0
  fi
  if [ "$BACKUP_READY" -eq 1 ] && [ "$PATCH_SUCCEEDED" -ne 1 ] && [ "$AUTO_ROLLBACK" -eq 1 ] && [ "$ROLLING_BACK" -ne 1 ]; then
    ROLLING_BACK=1
    printf 'Patch failed unexpectedly. Restoring backup: %s\n' "$BACKUP_DIR" >&2
    restore_backup "$BACKUP_DIR" >/dev/null 2>&1 || true
  fi
  exit "$status"
}

need_file "$PATCH_JS"
need_file "$MANIFEST"
need_file "$INNER_INFO"
need_file "$ASAR"

fail_after_backup() {
  printf '%s\n' "$1" >&2
  if [ "$AUTO_ROLLBACK" -eq 1 ]; then
    trap - ERR
    restore_backup "$BACKUP_DIR"
  fi
  exit 1
}

trap rollback_on_error ERR

VERSION="${VERSION:-}"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$INNER_INFO" 2>/dev/null || true)"
if [ -z "$VERSION" ]; then
  VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist" 2>/dev/null || true)"
fi

if [ -z "$VERSION" ]; then
  VERSION="unknown"
fi

case "$VERSION" in
  4.*)
    printf 'Detected Docker Desktop %s. Applying best-effort 4.x patch.\n' "$VERSION"
    ;;
  *)
    printf 'Detected Docker Desktop %s. This patcher is best-effort mode for unknown versions.\n' "$VERSION"
    ;;
esac

emit_progress 15 "检测到 Docker Desktop $VERSION"
emit_progress 25 "备份 Docker Desktop 原始文件"
mkdir -p "$BACKUP_DIR"
cp "$ASAR" "$BACKUP_DIR/app.asar"
cp "$INNER_INFO" "$BACKUP_DIR/Info.plist"
printf '%s\n' "$APP" > "$BACKUP_DIR/app-path.txt"
printf '%s\n' "$VERSION" > "$BACKUP_DIR/version.txt"
BACKUP_READY=1

if [ "$NO_RESTART" -eq 1 ]; then
  emit_progress 35 "保持 Docker Desktop 运行"
else
  emit_progress 35 "关闭 Docker Desktop"
  osascript -e 'tell application "Docker Desktop" to quit' >/dev/null 2>&1 || true
  pkill -x "Docker Desktop" >/dev/null 2>&1 || true
  sleep 2
fi

emit_progress 45 "解包 Docker Desktop 前端资源"
if [ -x "$PATCH_ROOT/scripts/asar.py" ]; then
  "$PATCH_ROOT/scripts/asar.py" extract "$ASAR" "$WORK_DIR/app"
elif command -v npx >/dev/null 2>&1; then
  npx --yes @electron/asar extract "$ASAR" "$WORK_DIR/app"
else
  fail_after_backup "Could not find ASAR tool. Missing bundled scripts/asar.py and npx is not available.\n"
fi

find_entry_html() {
  local html
  html="$(find "$WORK_DIR/app" -type f -path '*/desktop-ui-build/index.html' | sort | head -n 1 || true)"
  if [ -z "$html" ]; then
    html="$(find "$WORK_DIR/app" -type f -path '*/desktop-ui/index.html' | sort | head -n 1 || true)"
  fi
  if [ -z "$html" ]; then
    html="$(find "$WORK_DIR/app" -type f -name 'index.html' | sort | head -n 1 || true)"
  fi
  echo "$html"
}

find_entry_file() {
  local entry

  entry="$(find "$WORK_DIR/app" -type f -name 'entry-cli.main.js' | sort | head -n 1 || true)"
  if [ -z "$entry" ]; then
    entry="$(find "$WORK_DIR/app" -type f -name 'entry-*.main.js' | sort | head -n 1 || true)"
  fi
  if [ -z "$entry" ]; then
    entry="$(find "$WORK_DIR/app" -type f -name '*.main.js' | sort | head -n 1 || true)"
  fi
  echo "$entry"
}

find_bundle_assets_dir() {
  local html_path="$1"
  local base_dir
  base_dir="$(dirname "$html_path")"
  if [ -d "$base_dir/assets" ]; then
    echo "$base_dir/assets"
    return 0
  fi

  if [ -d "$WORK_DIR/app/desktop-ui-build/assets" ]; then
    echo "$WORK_DIR/app/desktop-ui-build/assets"
    return 0
  fi

  local dist_dir
  dist_dir="$(dirname "$base_dir")"
  if [ -d "$dist_dir/assets" ]; then
    echo "$dist_dir/assets"
    return 0
  fi

  echo "$base_dir/assets"
}

HTML="$(find_entry_html)"
ENTRY="$(find_entry_file)"

if [ -z "$HTML" ]; then
  fail_after_backup "Could not find a desktop UI HTML entry in the extracted app.asar.\n"
fi
need_file "$HTML"

ASSETS_DIR="$(find_bundle_assets_dir "$HTML")"
mkdir -p "$ASSETS_DIR"
TARGET_JS="$ASSETS_DIR/cn-patch.js"
cp "$PATCH_JS" "$TARGET_JS"

emit_progress 60 "注入中文语言补丁"
# Remove previously injected patch tags to keep idempotent behavior.
python3 - <<PY
import re
from pathlib import Path
p = Path("$HTML")
html = p.read_text(encoding="utf-8", errors="ignore")
patch = Path("$PATCH_JS").read_text(encoding="utf-8", errors="ignore").replace("</script>", "<\\/script>")
injection = (
    '<script id="docker-cn-patch">\n' + patch + '\n</script>\n'
    '<script id="docker-cn-patch-loader" type="module" src="./assets/cn-patch.js"></script>\n'
)
patterns = [
    re.compile(r"\n?\s*<script[^>]*cn-patch\.js[^>]*></script>", re.IGNORECASE),
    re.compile(r"\n?\s*<script[^>]*id=\"docker-cn-patch\"[^>]*>[\s\S]*?</script>", re.IGNORECASE),
]
for pattern in patterns:
    html = pattern.sub("", html)

if "</head>" in html:
    html = html.replace("</head>", injection + "</head>", 1)
else:
    if "</body>" in html:
        html = html.replace("</body>", injection + "</body>", 1)
    elif "<body" in html:
        m = re.search(r"<body[^>]*>", html, re.IGNORECASE)
        if not m:
            raise SystemExit("Could not find a safe script injection point in %s" % p)
        html = html[: m.end()] + "\n" + injection + html[m.end():]
    else:
        raise SystemExit("Could not find a safe script injection point in %s" % p)

p.write_text(html, encoding="utf-8")
PY

if [ -n "$ENTRY" ]; then
  TARGET_FILE="$ENTRY" MANIFEST_FILE="$MANIFEST" python3 - <<'PY'
import json
import os
import re
from pathlib import Path

entry = Path(os.environ['TARGET_FILE'])
manifest_path = Path(os.environ['MANIFEST_FILE'])

if not entry.exists() or not manifest_path.exists():
  raise SystemExit(0)

try:
  manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
except Exception as exc:
  print(f"Failed to read manifest: {exc}", flush=True)
  raise SystemExit(0)

rules = []
for item in manifest.get('nativeReplacements', []):
  if not isinstance(item, dict):
    continue
  replacements = item.get('replacements', [])
  hint = str(item.get('fileHint', '')).strip()
  for r in replacements:
    if not isinstance(r, dict):
      continue
    from_text = str(r.get('from', ''))
    to_text = str(r.get('to', ''))
    if not from_text:
      continue
    rules.append((hint, from_text, to_text))

if not rules:
  raise SystemExit(0)

source = entry.read_text(encoding='utf-8', errors='ignore')
changed = False

for hint, from_text, to_text in rules:
  if hint and hint not in entry.as_posix():
    continue
  if from_text in source:
    source = source.replace(from_text, to_text)
    changed = True

if changed:
  entry.write_text(source, encoding='utf-8')
PY
fi

emit_progress 75 "重新打包资源"
if [ -x "$PATCH_ROOT/scripts/asar.py" ]; then
  "$PATCH_ROOT/scripts/asar.py" pack "$WORK_DIR/app" "$WORK_DIR/app.asar"
elif command -v npx >/dev/null 2>&1; then
  npx --yes @electron/asar pack "$WORK_DIR/app" "$WORK_DIR/app.asar"
else
  fail_after_backup "Could not find ASAR tool. Missing bundled scripts/asar.py and npx is not available.\n"
fi
cp "$WORK_DIR/app.asar" "$ASAR"

emit_progress 82 "更新 Electron ASAR 完整性校验"
HASH="$(ASAR_PATH="$ASAR" python3 <<'PY'
import hashlib
import os
import struct

asar_path = os.environ["ASAR_PATH"]
with open(asar_path, "rb") as f:
    size_buf = f.read(8)
    if len(size_buf) != 8:
        raise SystemExit("Unable to read ASAR header size.")
    header_size = struct.unpack("<I", size_buf[4:8])[0]
    header_buf = f.read(header_size)
    if len(header_buf) != header_size:
        raise SystemExit("Unable to read ASAR header.")
    header_string_size = struct.unpack("<I", header_buf[4:8])[0]
    header_string = header_buf[8:8 + header_string_size]
    if header_string.endswith(b"\\0"):
        header_string = header_string[:-1]
    print(hashlib.sha256(header_string).hexdigest(), end="")
PY
)"
if /usr/libexec/PlistBuddy -c 'Print :ElectronAsarIntegrity:Resources/app.asar:hash' "$INNER_INFO" >/dev/null 2>&1; then
  /usr/libexec/PlistBuddy -c "Set :ElectronAsarIntegrity:Resources/app.asar:hash $HASH" "$INNER_INFO"
elif /usr/libexec/PlistBuddy -c 'Print :ElectronAsarIntegrity' "$INNER_INFO" >/dev/null 2>&1; then
  /usr/libexec/PlistBuddy -c "Set :ElectronAsarIntegrity:Resources:app.asar:hash $HASH" "$INNER_INFO"
fi

emit_progress 88 "清理 macOS 隔离属性"
xattr -cr "$APP"

printf 'Patch applied. Backup: %s\n' "$BACKUP_DIR"

if [ "$LAUNCH_AFTER_INSTALL" -eq 1 ]; then
  emit_progress 92 "启动 Docker Desktop 并等待前端"
  BEFORE_CRASH_COUNT="$(find "$HOME/Library/Logs/DiagnosticReports" -maxdepth 1 \( -name 'Docker Desktop*.ips' -o -name 'Docker Desktop*.crash' \) -newermt "-5 seconds" 2>/dev/null | wc -l | tr -d ' ')"
  open -a "$APP" >/dev/null 2>&1 || true
  FRONTEND_OK=0
  for _ in $(seq 1 45); do
    if pgrep -f 'Docker Desktop.app/Contents/MacOS/Docker Desktop' >/dev/null 2>&1; then
      FRONTEND_OK=1
      break
    fi
    sleep 1
  done
  if [ "$FRONTEND_OK" -ne 1 ]; then
    open "$INNER" >/dev/null 2>&1 || true
    sleep 3
  fi
  AFTER_CRASH_COUNT="$(find "$HOME/Library/Logs/DiagnosticReports" -maxdepth 1 \( -name 'Docker Desktop*.ips' -o -name 'Docker Desktop*.crash' \) -newermt "-15 seconds" 2>/dev/null | wc -l | tr -d ' ')"
  if [ "${AFTER_CRASH_COUNT:-0}" -gt "${BEFORE_CRASH_COUNT:-0}" ]; then
    fail_after_backup "Docker Desktop appears to have crashed after patching.\n"
  fi
  if ! pgrep -f 'Docker Desktop.app/Contents/MacOS/Docker Desktop' >/dev/null 2>&1; then
    fail_after_backup "Docker Desktop frontend did not stay running after patching.\n"
  fi

  emit_progress 96 "等待 Docker 引擎可用"
  ENGINE_OK=0
  if command -v docker >/dev/null 2>&1; then
    for _ in $(seq 1 60); do
      if server_version="$(docker version --format '{{.Server.Version}}' 2>/dev/null)" && [ -n "$server_version" ]; then
        ENGINE_OK=1
        break
      fi
      sleep 2
    done
  else
    for _ in $(seq 1 60); do
      if pgrep -f 'com.docker.backend' >/dev/null 2>&1; then
        ENGINE_OK=1
        break
      fi
      sleep 2
    done
  fi
  if [ "$ENGINE_OK" -ne 1 ]; then
    fail_after_backup "Docker Engine did not become available after patching.\n"
  fi
  emit_progress 100 "完成"
  printf 'Docker Desktop frontend launch requested.\n'
elif [ "$NO_RESTART" -eq 1 ]; then
  emit_progress 100 "完成；Docker Desktop 下次刷新或重新打开后生效"
  printf 'Patch applied without restarting Docker Desktop. Reopen or reload Docker Desktop to see the patch if it was not already active.\n'
fi
PATCH_SUCCEEDED=1
