# Docker Desktop CN Patcher（通用版）

这是一个面向 macOS 的 Docker Desktop 汉化补丁包。当前安全热修版已暂停写入 Docker.app，避免破坏 Docker Desktop 官方签名；主要用于恢复原始 Docker、查看备份和收集日志。

## 推荐安装方式（DMG 图形 App，给其他 Mac 使用）

1. 打开 DMG
2. 双击 `DockerCN-Patcher.app`
3. 如果 Docker Desktop 打不开，点击“恢复原始 Docker”
4. App 会打开一个临时 Terminal 窗口，请在 Terminal 里输入管理员密码
5. 不要关闭窗口，下方会实时显示进度和日志

这是推荐分发方式：用户只需要打开 DMG 里的 App，就能恢复原始 Docker、查看备份和错误日志。

## 可视化工具（App）

1. 打开 `DockerCN-Patcher.app`
2. 当前“安装”已暂停
3. 如需修复打不开的问题，点击“恢复原始 Docker”
4. 等待进度到 100%，窗口下方会持续显示日志

图形 App 和 PKG 默认使用安全验证模式：先备份，再写入补丁，然后短暂关闭并重新唤醒 Docker Desktop；确认没有崩溃且 Docker Engine 正常后才算成功。如果验证失败，会自动恢复安装前备份，避免“安装时成功、下次打开才坏”的情况。

如果 Terminal 提示输入密码，输入时不会显示字符，这是 macOS 正常行为。如果 macOS 的“应用管理/App Management”提示 Terminal 想修改应用，请允许。后续通常只需要授权一次。

说明：密码窗口是 macOS 系统授权框，本工具不会保存密码。


## 给别人测试建议

发给别人测试时，建议直接发 DMG，并让对方双击 `DockerCN-Patcher.app`。

原因：图形 App 能显示实时进度和完整日志，用户反馈问题时更容易定位。

测试反馈时请让对方提供：

- Docker Desktop 版本
- macOS 版本
- `/var/log/docker-cn-patcher-install.log` 最后 50 行
- 截图中仍未汉化的英文原文

## 出错怎么处理

App 窗口会显示当前失败阶段，例如：

- 检测 Docker Desktop
- 备份原始文件
- 解包前端资源
- 注入中文语言补丁
- 重新打包资源
- 更新 ASAR 完整性校验
- 启动 Docker Desktop
- 等待 Docker 引擎可用

如果失败，窗口会显示错误原因提示，并保留日志。点击“打开日志”可以定位日志文件。

如果失败阶段是“检查 Docker.app 写入权限”，说明 macOS 还没有允许 Terminal 修改其他应用：

```text
系统设置 > 隐私与安全性 > 应用管理 > 允许 Terminal
```

授权后重新点击“安装 / 重新汉化”即可。

如果 Docker Desktop 打不开，点击 App 里的“恢复原始 Docker”。也可以使用命令行：

```bash
./rollback.sh
```

备份目录：

```text
~/.docker-desktop-cn-patcher/backups
```

## 权限说明

PKG 会通过 macOS Installer 获取管理员权限，是推荐路径。图形 App 也会请求管理员权限，但某些 macOS 版本可能额外限制普通 App 修改 `/Applications` 内的其他应用：

- 密码框由 macOS 系统弹出
- 本工具不会保存密码
- 用户取消授权时，不会继续修改 Docker
- 同一个签名后的 App 通常只需要授权一次；如果移动 App 路径、重新下载或重新签名，macOS 可能会再次询问

如果用户取消授权，补丁不会继续执行，也不会修改 Docker。

## 支持范围

- 已验证：`4.76.0`；`4.74.0` 已新增外部 UI 资源 fallback，需要异机复测
- 兼容策略：Docker Desktop `4.x` 使用通用 best-effort 注入
- 说明：Docker 更新后通常只需要重新运行补丁；如果新版新增英文文案，需要补充 `assets/cn-patch.js` 词典。

## 命令行安装

```bash
chmod +x install.sh rollback.sh build-dmg.sh build-app.sh
./install.sh --app "/Applications/Docker.app"
```

只打补丁、不自动启动 Docker：

```bash
./install.sh --no-launch
```

安装但不主动重启 Docker Desktop：

```bash
./install.sh --no-restart
```

`--no-restart` 会跳过 Docker Desktop 前端重启验证，只适合已经确认当前 Docker Desktop 版本兼容时使用。给其他 Mac 分发时，建议使用默认安装模式。

恢复最近备份：

```bash
./install.sh --restore-latest --app "/Applications/Docker.app"
```

列出备份：

```bash
./install.sh --list-backups
```

## 构建 App 和 DMG

构建原生安装 App：

```bash
./build-app.sh
```

构建可分发 DMG：

```bash
./build-dmg.sh
```

单独构建 PKG：

```bash
./build-pkg.sh
```

输出：

```text
dist/DockerDesktop-CN-Patcher-YYYYMMDD.dmg
```

DMG 内包含：

- `DockerCN-Patcher.app`
- `Applications` 快捷方式
- `使用说明.txt`

普通用户直接双击 App 安装；App 可用于查看日志、手动恢复原始 Docker、打开备份目录。

App 内已经内置 ASAR 解包/打包工具，不要求用户电脑预装 Node.js、npm 或 npx。

## 升级 Docker Desktop 后

Docker Desktop 更新通常会覆盖 `app.asar`，所以更新后重新运行 `DockerCN-Patcher.app` 即可。

如果汉化后某些新页面仍有英文，把英文原文加入 `assets/cn-patch.js` 的词典，再重新构建/安装即可。
