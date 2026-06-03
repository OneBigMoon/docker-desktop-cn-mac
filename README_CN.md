# Docker Desktop CN Patcher

这是一个 Docker Desktop for Mac 汉化补丁包。它会在安装时解包 Docker Desktop 的 `app.asar`，注入前端汉化脚本，并修正目前已知的少量原生菜单文案。

## 支持范围

- 已测试：Docker Desktop `4.69.0`
- 兼容策略：Docker Desktop `4.x` 尽力兼容
- 不建议翻译：`Docker Hub`、`Kubernetes`、`containerd`、`Docker VMM`、日志输出、镜像名、命令参数、套餐名等专有或技术文本

## 安装

```bash
chmod +x install.sh rollback.sh build-dmg.sh
./install.sh
```

如果 Docker 不在默认路径：

```bash
./install.sh --app "/Applications/Docker.app"
```

安装脚本会自动备份原始文件，备份目录在：

```text
~/.docker-desktop-cn-patcher/backups
```

## 回滚

回滚到最近一次备份：

```bash
./rollback.sh
```

回滚到指定备份：

```bash
./rollback.sh "$HOME/.docker-desktop-cn-patcher/backups/20260603-120000"
```

## 生成 DMG

```bash
./build-dmg.sh
```

生成文件会放在：

```text
docker-desktop-cn-patcher/dist
```

## 说明

Docker Desktop 每次升级后都可能覆盖补丁。升级后重新运行 `./install.sh` 即可。

如果某个新版本界面里出现新的英文文案，优先把文案加入 `assets/cn-patch.js` 的词典。补丁器会在安装时把这个文件注入到 Docker Desktop 前端资源里。
