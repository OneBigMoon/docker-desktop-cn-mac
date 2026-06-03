# Docker Desktop 中文补丁（macOS）

这是一个 Docker Desktop for Mac 汉化补丁工具，目标是给普通用户一个尽量简单、安全、可恢复的安装方式。

## 当前状态

- 已测试 Docker Desktop：`4.76.0`；`4.74.0` 已新增外部 UI 资源 fallback，需要异机复测
- 兼容策略：Docker Desktop `4.x` 尽力兼容
- 默认安装方式：`PKG` 安装包
- 默认安装行为：先备份，再汉化，不主动重启 Docker Desktop
- 失败保护：补丁写入失败会自动恢复最近备份
- 手动恢复：支持一键恢复原始 Docker

## 推荐给别人测试的方式

1. 下载或打开 DMG：

   ```text
   DockerDesktop-CN-Patcher-YYYYMMDD.dmg
   ```

2. 双击安装包：

   ```text
   DockerDesktop-CN-Patcher-0.4.2.pkg
   ```

3. 按 macOS Installer 提示输入管理员密码。

4. 安装完成后，重新打开 Docker Desktop 前端，或等待 Docker Desktop 自己刷新界面。

说明：安装默认不会主动重启 Docker Desktop，也不会中断 Docker Engine。

## DMG 里面有什么

```text
DockerCN-Patcher.app
DockerDesktop-CN-Patcher-0.4.2.pkg
Applications
使用说明.txt
```

普通用户优先使用 `pkg` 安装。`DockerCN-Patcher.app` 主要用于可视化安装、查看日志、打开备份目录和恢复原始 Docker。

## 为什么推荐 PKG

macOS 对普通 App 修改 `/Applications` 里的其他 App 有额外的“应用管理/App Management”限制。`pkg` 由系统 Installer 执行，授权链路更稳定，适合发给别人测试。

图形 App 也支持安装，但如果被 macOS 拦截，请改用 `pkg`。

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
