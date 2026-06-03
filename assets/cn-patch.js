const dictionary = new Map(Object.entries({
  "Search": "搜索",
  "Update available": "有可用更新",
  "Outdated version": "版本已过期",
  "Open terminal": "打开终端",
  "Close terminal": "关闭终端",
  "open app switcher": "打开应用切换器",
  "Upgrade plan": "升级套餐",
  "PERSONAL": "个人版",
  "Start Docker Desktop when you sign in to your computer": "登录电脑时启动 Docker Desktop",
  "Automatically (edits your shell configuration)": "自动配置（编辑你的 Shell 配置）",
  "Re-install": "重新安装",
  "Regularly checks your configuration to ensure no unexpected changes have been made by another application.": "定期检查你的配置，确保没有被其他应用意外更改。",
  "This can prevent Docker from starting, reset your daemon settings if it hangs.": "这可能会导致 Docker 无法启动；如果卡住，请重置守护进程设置。",
  "Configure the Docker daemon by typing a JSON Docker daemon": "通过输入 JSON Docker 守护进程配置来配置 Docker 守护进程",
  "Extensions run with host-level privileges": "扩展会以主机级权限运行",
  "They can access Docker Engine, read and write to your filesystem, and install native binaries. Docker reviews Marketplace extensions but does not security-audit them. Only install extensions from publishers you trust.": "它们可以访问 Docker 引擎、读写你的文件系统，并安装原生二进制文件。Docker 会审核市场扩展，但不会进行安全审计。请只安装你信任的发布者提供的扩展。",
  "Turning this option off uninstalls all extensions and disables all extension features.": "关闭此选项会卸载所有扩展并禁用全部扩展功能。",
  "Only allow extensions distributed through the Docker Marketplace": "仅允许通过 Docker 市场分发的扩展",
  "Prevents the installation of any other extension via the Extension SDK tools.": "阻止通过扩展 SDK 工具安装其他扩展。",
  "Displays Docker Desktop Extensions internal containers when using Docker commands.": "使用 Docker 命令时显示 Docker Desktop 扩展的内部容器。",
  "Host networking allows containers that are started with --net=host use localhost to connect to TCP and UDP services on the host. It automatically allows software on the host to use localhost to connect to TCP and UDP services in the container.": "主机网络允许使用 --net=host 启动的容器通过 localhost 连接主机上的 TCP 和 UDP 服务，也会自动允许主机软件通过 localhost 连接容器中的 TCP 和 UDP 服务。",
  "Docker networks set to support only IPv4 by default. This can be overriden on a per-network basis.": "Docker 网络默认仅支持 IPv4。可按单个网络覆盖此设置。",
  "Docker is set to detect whether your host supports IPv4 and/or IPv6. It automatically filters unsupported DNS record types (A or AAAA) to prevent containers from attempting failed connections This can be overriden on a per-network basis.": "Docker 会检测你的主机是否支持 IPv4 和/或 IPv6，并自动过滤不受支持的 DNS 记录类型（A 或 AAAA），防止容器尝试失败的连接。可按单个网络覆盖此设置。",
  "Checking for updates": "正在检查更新",
  "Check for updates": "检查更新",
  "Download update": "下载更新",
  "Download update...": "下载更新...",
  "Downloading update": "正在下载更新",
  "Install update": "安装更新",
  "Install and restart": "安装并重启",
  "Restart to update": "重启以更新",
  "Skip this version": "跳过此版本",
  "Release notes": "发行说明",
  "You are up to date": "已是最新版本",
  "An update is available": "有可用更新",
  "A new version is available": "有新版本可用",
  "New version available": "有新版本可用",
  "Automatically check for updates": "自动检查更新",
  "Always download updates": "始终下载更新",
  "Include pre-releases": "包含预发布版本",
  "启动时打开打开 Docker 面板": "启动时打开 Docker 面板",
  "Beat 功能": "Beta 功能",
  "Dashboard": "仪表盘",
  "Local": "本地",
  "Containers": "容器",
  "Images": "镜像",
  "Volumes": "卷",
  "Builds": "构建",
  "Models": "模型",
  "Logs": "日志",
  "Extensions": "扩展",
  "Settings": "设置",
  "Troubleshoot": "故障排除",
  "Notifications": "通知",
  "Learning Center": "学习中心",
  "Resource Saver": "资源节省器",
  "Resource Saver mode": "资源节省模式",
  "Engine running": "引擎运行中",
  "Docker is running": "Docker 正在运行",
  "Gordon agent is starting...": "Gordon 助手正在启动...",
  "Restart": "重启",
  "Resume": "恢复",
  "Pause": "暂停",
  "Preferences": "偏好设置",
  "Sign in": "登录",
  "Sign out": "退出登录",
  "Copy": "复制",
  "Paste": "粘贴",
  "Cut": "剪切",
  "Undo": "撤销",
  "Redo": "重做",
  "Select All": "全选",
  "Save": "保存",
  "Cancel": "取消",
  "Delete": "删除",
  "Remove": "移除",
  "Clear": "清除",
  "Clear all": "全部清除",
  "Refresh": "刷新",
  "Retry": "重试",
  "Back": "返回",
  "Next": "下一步",
  "Previous": "上一步",
  "Finish": "完成",
  "Done": "完成",
  "Close": "关闭",
  "Open": "打开",
  "Create": "创建",
  "Apply": "应用",
  "Reset": "重置",
  "Import": "导入",
  "Export": "导出",
  "Download": "下载",
  "Upload": "上传",
  "View": "查看",
  "Edit": "编辑",
  "More actions": "更多操作",
  "No results": "没有结果",
  "No data": "没有数据",
  "Loading": "正在加载",
  "Loading...": "正在加载...",
  "Marketplace": "市场",
  "Browse models": "浏览模型",
  "Tiny LLM built for speed, edge devices, and local development": "为速度、边缘设备和本地开发打造的小型 LLM",
  "Solid LLaMA 3 update, reliable for coding, chat, and Q&A tasks": "可靠的 LLaMA 3 更新，适合编码、聊天和问答任务",
  "Google’s latest Gemma, small yet strong for chat and generation": "Google 最新的 Gemma，小巧但适合聊天与生成任务",
  "Extensions Marketplace": "扩展市场",
  "Container filters": "容器筛选",
  "Search container": "搜索容器",
  "Saved searches": "已保存的搜索",
  "Save current search": "保存当前搜索",
  "Search filter name": "搜索筛选名称",
  "Add search filter": "添加搜索筛选",
  "Wrap lines": "自动换行",
  "Show timestamps": "显示时间戳",
  "View build logs": "查看构建日志",
  "No saved searches": "没有已保存的搜索",
  "Some regex filters were skipped": "已跳过部分正则筛选",
  "This repository doesn't have an overview.": "此仓库没有概览。",
  "This compose file doesn't contain any images.": "此 Compose 文件不包含任何镜像。",
  "This saved filter contains unsafe regex patterns that will be skipped": "此已保存筛选包含不安全的正则模式，将被跳过",
  "This regex filter was skipped because it may cause performance issues": "此正则筛选可能影响性能，已被跳过",
  "Tip: use regex like": "提示：可以使用类似这样的正则表达式"
}));

const patternDictionary = [
  [/^Version (.+) is available to download$/i, "版本 $1 可供下载"],
  [/^running in Resource Saver mode$/i, "正在资源节省模式下运行"],
  [/^Add search filter \(supports regex like "(.+)"\)$/i, "添加搜索筛选（支持类似 \"$1\" 的正则）"]
];

const translate = (value) => {
  if (!value || typeof value !== "string") return value;
  const trimmed = value.trim();
  const direct = dictionary.get(trimmed);
  if (direct) return value.replace(trimmed, direct);
  for (const [pattern, replacement] of patternDictionary) {
    if (pattern.test(trimmed)) return value.replace(trimmed, trimmed.replace(pattern, replacement));
  }
  return value;
};

const translateNode = (node) => {
  if (node.nodeType === Node.TEXT_NODE) {
    const translated = translate(node.nodeValue);
    if (translated !== node.nodeValue) node.nodeValue = translated;
    return;
  }
  if (node.nodeType !== Node.ELEMENT_NODE) return;
  for (const attr of ["title", "aria-label", "placeholder", "alt", "data-tooltip", "data-title"]) {
    if (node.hasAttribute(attr)) {
      const current = node.getAttribute(attr);
      const translated = translate(current);
      if (translated !== current) node.setAttribute(attr, translated);
    }
  }
  for (const child of node.childNodes) translateNode(child);
};

const run = () => {
  if (document.body) translateNode(document.body);
};

const observer = new MutationObserver((mutations) => {
  for (const mutation of mutations) {
    if (mutation.type === "characterData") translateNode(mutation.target);
    for (const node of mutation.addedNodes) translateNode(node);
    if (mutation.type === "attributes") translateNode(mutation.target);
  }
});

run();
if (document.body) {
  observer.observe(document.body, {
    childList: true,
    subtree: true,
    characterData: true,
    attributes: true,
    attributeFilter: ["title", "aria-label", "placeholder", "alt", "data-tooltip", "data-title"]
  });
}

window.DockerDesktopCNPatch = { run, dictionary };
