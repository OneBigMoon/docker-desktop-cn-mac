#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SOURCE_APP="/Applications/Docker.app"
DEST_APP="/Applications/DockerCN.app"
STATE_DIR="$HOME/.docker-desktop-cn-patcher"
LAUNCH_PATH_BACKUP="$STATE_DIR/original-launch-path.txt"
SETTINGS_FILE="$HOME/Library/Group Containers/group.com.docker/settings-store.json"
ACTION="install"
FORCE=0
UNSAFE_RUN_ANYWAY=0

usage() {
  cat <<'EOF'
Usage:
  ./build-local-experimental.sh --restore
  ./build-local-experimental.sh --unsafe-run-anyway [--force]

Restore mode is safe and switches Docker Desktop back to /Applications/Docker.app.

The experimental DockerCN.app copy mode is disabled by default.
Reason: Docker Desktop has privileged virtualization, keychain, app group and
launchd requirements tied to Docker's official signing chain. Re-signing a copy
can make Docker Desktop fail to launch even when codesign verification passes.

Only use --unsafe-run-anyway for debugging on a disposable test machine.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --force)
      FORCE=1
      shift
      ;;
    --unsafe-run-anyway)
      UNSAFE_RUN_ANYWAY=1
      shift
      ;;
    --restore)
      ACTION="restore"
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

need_file() {
  if [ ! -e "$1" ]; then
    printf 'Missing: %s\n' "$1" >&2
    exit 1
  fi
}

run_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
    return
  fi

  if [ -t 0 ]; then
    /usr/bin/sudo "$@"
    return
  fi

  local command=""
  local quoted
  for arg in "$@"; do
    printf -v quoted '%q' "$arg"
    command+="$quoted "
  done

  COMMAND="$command" python3 <<'PY' >/tmp/dockercn-admin.applescript
import json
import os
print("do shell script " + json.dumps(os.environ["COMMAND"]) + " with administrator privileges")
PY
  /usr/bin/osascript /tmp/dockercn-admin.applescript
}

quit_docker() {
  osascript -e 'tell application "Docker Desktop" to quit' >/dev/null 2>&1 || true
  pkill -x "Docker Desktop" >/dev/null 2>&1 || true
  pkill -f "/Applications/Docker.app/Contents/MacOS/com.docker.backend" >/dev/null 2>&1 || true
  pkill -f "/Applications/DockerCN.app/Contents/MacOS/com.docker.backend" >/dev/null 2>&1 || true
  sleep 5
}

set_launch_path() {
  local new_path="$1"
  mkdir -p "$STATE_DIR"
  SETTINGS_FILE="$SETTINGS_FILE" NEW_PATH="$new_path" BACKUP_PATH="$LAUNCH_PATH_BACKUP" python3 <<'PY'
import json
import os
from pathlib import Path

settings = Path(os.environ["SETTINGS_FILE"])
backup = Path(os.environ["BACKUP_PATH"])
new_path = os.environ["NEW_PATH"]

if not settings.exists():
    raise SystemExit(0)

data = json.loads(settings.read_text(encoding="utf-8"))
old_path = data.get("DockerAppLaunchPath") or "/Applications/Docker.app"
if not backup.exists():
    backup.write_text(old_path + "\n", encoding="utf-8")
data["DockerAppLaunchPath"] = new_path
settings.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"DockerAppLaunchPath: {old_path} -> {new_path}")
PY
}

restore_launch_path() {
  local original="/Applications/Docker.app"
  if [ -f "$LAUNCH_PATH_BACKUP" ]; then
    original="$(head -n 1 "$LAUNCH_PATH_BACKUP" || true)"
    if [ -z "$original" ]; then
      original="/Applications/Docker.app"
    fi
  fi
  set_launch_path "$original"
}

wait_for_engine() {
  local ok=0
  for _ in $(seq 1 60); do
    if docker version --format 'client={{.Client.Version}} server={{.Server.Version}}' >/tmp/dockercn-engine-version.txt 2>/tmp/dockercn-engine.err; then
      ok=1
      break
    fi
    sleep 2
  done
  if [ "$ok" -ne 1 ]; then
    cat /tmp/dockercn-engine.err >&2 || true
    return 1
  fi
  cat /tmp/dockercn-engine-version.txt
}

if [ "$ACTION" = "restore" ]; then
  printf 'Restoring Docker Desktop launch path to original app...\n'
  restore_launch_path
  quit_docker
  open -na "$SOURCE_APP"
  wait_for_engine || true
  printf 'Restore command finished. Original app: %s\n' "$SOURCE_APP"
  exit 0
fi

need_file "$SOURCE_APP"
need_file "$ROOT/install.sh"

if [ "$UNSAFE_RUN_ANYWAY" -ne 1 ]; then
  cat >&2 <<'EOF'
Refusing to create /Applications/DockerCN.app in safe mode.

This local-copy experiment is known to be unreliable on current Docker Desktop:
macOS launchd can reject the re-signed Docker copy because Docker's backend uses
privileged entitlements tied to Docker's official signing team.

Safe action available:
  ./build-local-experimental.sh --restore

Debug-only override for disposable test machines:
  ./build-local-experimental.sh --unsafe-run-anyway --force
EOF
  exit 2
fi

if [ -e "$DEST_APP" ] && [ "$FORCE" -ne 1 ]; then
  printf '%s already exists. Re-run with --force to replace it.\n' "$DEST_APP" >&2
  exit 1
fi

printf 'Checking original Docker.app signature...\n'
codesign --verify --deep --strict "$SOURCE_APP"

printf 'Stopping Docker Desktop before copying...\n'
quit_docker

printf 'Copying Docker.app to DockerCN.app...\n'
run_root rm -rf "$DEST_APP"
run_root /usr/bin/ditto "$SOURCE_APP" "$DEST_APP"
run_root chown -R "$USER":staff "$DEST_APP"
xattr -cr "$DEST_APP" || true

printf 'Applying Chinese patch to the copy only...\n'
"$ROOT/install.sh" --app "$DEST_APP" --allow-unsafe-patch --no-restart

printf 'Ad-hoc signing DockerCN.app for this Mac while preserving Docker entitlements...\n'
codesign --force --deep --sign - --preserve-metadata=identifier,entitlements,flags,runtime "$DEST_APP"

printf 'Verifying DockerCN.app signature...\n'
codesign --verify --deep --strict --verbose=2 "$DEST_APP"

printf 'Pointing Docker Desktop launch path to DockerCN.app...\n'
set_launch_path "$DEST_APP"

printf 'Launching DockerCN.app...\n'
quit_docker
open -na "$DEST_APP"

printf 'Waiting for Docker Engine...\n'
wait_for_engine

printf 'Experimental local DockerCN.app is ready: %s\n' "$DEST_APP"
printf 'To go back to the original Docker.app, run:\n'
printf '  ./build-local-experimental.sh --restore\n'
