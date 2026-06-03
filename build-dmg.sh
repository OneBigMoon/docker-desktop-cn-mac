#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="$ROOT/dist"
OUT="$OUT_DIR/DockerDesktop-CN-Patcher-$(date +%Y%m%d).dmg"
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/docker-cn-dmg.XXXXXX")"
cleanup() { rm -rf "$STAGE"; }
trap cleanup EXIT

"$ROOT/build-app.sh"
mkdir -p "$OUT_DIR"
cp -R "$ROOT/build/DockerCN-Patcher.app" "$STAGE/DockerCN-Patcher.app"
cat > "$STAGE/使用说明.txt" <<'TXT'
Docker Desktop 汉化补丁安全热修版

当前状态：
此版本已暂停写入 Docker.app，避免破坏 Docker Desktop 官方签名。
如果 Docker Desktop 打不开，请使用“恢复原始 Docker”。

推荐用法：
1. 双击 DockerCN-Patcher.app。
2. 如果 Docker Desktop 打不开，点击“恢复原始 Docker”。
3. App 会打开一个临时 Terminal 窗口，请在 Terminal 里输入管理员密码。
4. 不要关闭窗口，下方会实时显示进度和日志。

如果失败：
1. 窗口会显示失败阶段和错误原因。
2. 点击“打开日志”查看完整日志。
3. 如果 Docker Desktop 打不开，点击“恢复原始 Docker”。
4. 如果提示“检查 Docker.app 写入权限”失败，请到“系统设置 > 隐私与安全性 > 应用管理”允许 Terminal，然后重新安装。

说明：
- 安装前会自动备份 Docker Desktop 原始文件。
- 安装失败会自动尝试恢复备份。
- 恢复不会删除容器、镜像、卷或 Docker 设置。
- 如果 Terminal 提示输入密码，输入时不会显示字符，这是 macOS 正常行为。
- 如果 macOS 提示 Terminal 想修改应用，请允许。
TXT
ln -s /Applications "$STAGE/Applications"
hdiutil create -volname "Docker Desktop CN Patcher" -srcfolder "$STAGE" -ov -format UDZO "$OUT"
open -R "$OUT"
printf 'Created: %s\n' "$OUT"
