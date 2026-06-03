# Docker Desktop 中文补丁（macOS）

这是一个 Docker Desktop for Mac 汉化补丁工具，目标是给普通用户一个尽量简单、安全、可恢复的安装方式。

## 当前状态

- 已测试 Docker Desktop：`4.76.0`；`4.74.0` 已新增外部 UI 资源 fallback，需要异机复测
- 兼容策略：Docker Desktop `4.x` 尽力兼容
- 默认安装方式：打开 DMG 后直接运行 `DockerCN-Patcher.app`
- 默认安装行为：先备份，再汉化，再唤醒 Docker Desktop 并检查崩溃和 Docker Engine
- 失败保护：补丁写入失败会自动恢复最近备份
- 手动恢复：支持一键恢复原始 Docker

## 推荐给别人测试的方式

1. 下载或打开 DMG：

   ```text
   DockerDesktop-CN-Patcher-YYYYMMDD.dmg
   ```

2. 双击图形工具：

   ```text
   DockerCN-Patcher.app
   ```

3. 点击“安装 / 重新汉化”，App 会打开临时 Terminal 窗口，请在 Terminal 里输入管理员密码。

4. 不要关闭窗口，下方会实时显示进度和日志；确认没有崩溃且 Docker Engine 正常后才算成功。

说明：默认安装会验证下一次启动是否出现崩溃；如果验证失败，会自动恢复安装前备份，避免“当时成功、下次打不开”的情况。命令行仍保留 `--no-restart` 高级选项，但不建议给未知 Docker 版本使用。

## DMG 里面有什么

```text
DockerCN-Patcher.app
Applications
使用说明.txt
```

普通用户直接双击 `DockerCN-Patcher.app`。窗口里会显示进度、日志、备份目录和“恢复原始 Docker”按钮。

## PKG 怎么处理

`build-pkg.sh` 仍保留，适合作为备用安装包。但正式分发建议优先发 DMG，让用户直接打开图形 App，这样能看到进度和日志。

如果 Terminal 提示输入密码，输入时不会显示字符，这是 macOS 正常行为。如果 macOS 拦截修改 `/Applications/Docker.app`，请到“系统设置 > 隐私与安全性 > 应用管理”允许 Terminal 修改应用，后续通常只需要授权一次。

## 备份与恢复

每次安装前都会备份 Docker Desktop 的关键文件：

```text
~/.docker-desktop-cn-patcher/backups
```

恢复最近备份：

```bash
./install.sh --restore-latest --app "/Applications/Docker.app"
```

或使用图形 App 里的：

```text
恢复原始 Docker
```

恢复只会恢复 Docker Desktop 的前端资源和 `Info.plist`，不会删除容器、镜像、卷和 Docker 设置。

## 日志位置

PKG 安装日志：

```text
/var/log/docker-cn-patcher-install.log
```

图形 App 日志：

```text
~/Library/Logs/DockerCN-Patcher/
```

安装失败时，请优先看日志最后几十行。

## Docker 更新后怎么办

Docker Desktop 更新通常会覆盖 `app.asar`，所以更新后重新运行 `pkg` 或图形 App 即可。

如果新版出现新的英文文案，需要补充：

```text
assets/cn-patch.js
```

然后重新构建安装包。

## 从源码构建

构建 App：

```bash
./build-app.sh
```

构建 PKG：

```bash
./build-pkg.sh
```

构建 DMG：

```bash
./build-dmg.sh
```

输出目录：

```text
dist/
```

## 命令行安装

```bash
./install.sh --app "/Applications/Docker.app" --no-restart
```

`--no-restart` 会跳过 Docker Desktop 前端重启验证，只适合你已经确认当前 Docker Desktop 版本可用时使用。正式分发给其他 Mac 时，建议使用默认安装模式。

完整安装并启动检查：

```bash
./install.sh --app "/Applications/Docker.app"
```

列出备份：

```bash
./install.sh --list-backups
```

恢复最近备份：

```bash
./install.sh --restore-latest --app "/Applications/Docker.app"
```

## 已知限制

- 当前只在 Docker Desktop `4.76.0` 上完整测试。
- Docker 新版可能新增英文文案，需要继续补词典。
- `PERSONAL`、`BETA`、`Docker Hub`、`Gordon` 等产品名通常保留英文。
- macOS 菜单栏里的 `Edit`、`View` 属于系统/原生菜单层，不属于当前前端补丁范围。
- 如果没有 Developer ID 签名和 notarization，其他 Mac 可能出现 Gatekeeper 提示。

## 安全设计

安装流程：

```text
检测 Docker Desktop
备份原始 app.asar 和 Info.plist
解包 app.asar
注入中文补丁
重新打包 app.asar
更新 Electron ASAR 完整性 hash
清理隔离属性
完成
```

如果备份完成后任意阶段失败，会自动尝试恢复备份。
