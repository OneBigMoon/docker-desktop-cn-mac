(() => {
  if (window.__DockerDesktopCNPatchLoaded) return;
  window.__DockerDesktopCNPatchLoaded = true;

const dictionary = new Map(Object.entries({
  "Search": "搜索",
  "Give feedback": "反馈",
  "Learn more": "了解更多",
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
  "Configure the Docker daemon by typing a JSON Docker daemon": "通过输入 JSON 格式的 Docker 守护进程",
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
  "Software updates preferences": "软件更新偏好设置",
  "Automatically download new updates in background.": "在后台自动下载新更新。",
  "Automatically update components": "自动更新组件",
  "Allow Docker Desktop to automatically update components that don't require a restart.": "允许 Docker Desktop 自动更新无需重启的组件。",
  "To check for updates, select the version number in the footer.": "要检查更新，请选择底部的版本号。",
  "Include pre-releases": "包含预发布版本",
  "启动时打开打开 Docker 面板": "启动时打开 Docker 面板",
  "Beat 功能": "Beta 功能",
  "Dashboard": "仪表盘",
  "Docker Home": "Docker 主页",
  "Explore and manage your Docker experience.": "探索和管理你的 Docker 使用体验。",
  "Docker Admin Console": "Docker 管理控制台",
  "Manage users, control access, & set policies.": "管理用户、控制访问并设置策略。",
  "Find and share images with your team.": "与团队查找和共享镜像。",
  "Docker Scout": "Docker Scout",
  "Secure your supply chain at every level.": "在各个层级保护你的供应链。",
  "Docker Build Cloud": "Docker 构建云",
  "Speed up your builds.": "加速你的构建。",
  "Testcontainers Cloud": "Testcontainers 云",
  "Run integration tests with real dependencies.": "使用真实依赖运行集成测试。",
  "NEW": "新",
  "General": "通用",
  "Resources": "资源",
  "Docker Engine": "Docker 引擎",
  "Builders": "构建器",
  "Software updates": "软件更新",
  "Beta features": "Beta 功能",
  "Search settings": "搜索设置",
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
  "Learning center": "学习中心",
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
  "Light": "浅色",
  "Dark": "深色",
  "Use system settings": "跟随系统设置",
  "Open Docker Dashboard when Docker Desktop starts": "Docker Desktop 启动时打开 Docker 面板",
  "Choose theme for Docker Desktop": "选择 Docker Desktop 主题",
  "Configure shell completions": "配置 Shell 补全",
  "Detected shell:": "检测到的 Shell：",
  "Choose container terminal": "选择容器终端",
  "Integrated": "内置",
  "System default": "系统默认",
  "Alternatively, you can manually edit your shell configuration.": "也可以手动编辑你的 Shell 配置。",
  "Your running containers show up here": "正在运行的容器会显示在这里",
  "A container is an isolated environment for your code": "容器是用于运行代码的隔离环境",
  "What is a container?": "什么是容器？",
  "How do I run a container?": "如何运行容器？",
  "View more in the Learning center": "查看更多学习中心内容",
  "Images are used to run containers": "镜像用于运行容器",
  "In this guide, you create an image using a Dockerfile - a text file that defines the steps for building an image - and a sample application.": "在本指南中，你会使用 Dockerfile 创建镜像。Dockerfile 是定义镜像构建步骤的文本文件，并会配合一个示例应用。",
  "Get the sample application": "获取示例应用",
  "Verify your Dockerfile": "验证 Dockerfile",
  "Marketplace": "市场",
  "Browse models": "浏览模型",
  "My Hub": "我的 Hub",
  "Name": "名称",
  "Tag": "标签",
  "Image ID": "镜像 ID",
  "Created": "创建时间",
  "Size": "大小",
  "Actions": "操作",
  "Unused": "未使用",
  "Copy to clipboard": "复制到剪贴板",
  "Ask Gordon": "询问 Gordon",
  "Run": "运行",
  "Show image actions": "显示镜像操作",
  "Select row": "选择行",
  "Select all rows": "选择所有行",
  "Showing  1 item": "显示 1 项",
  "Walkthroughs": "教程",
  "Run Docker Hub images": "运行 Docker Hub 镜像",
  "Open images toolbar": "打开镜像工具栏",
  "refresh": "刷新",
  "filter": "筛选",
  "Engine total memory usage. This includes containers plus overheads.": "引擎总内存用量，包括容器和额外开销。",
  "Engine total CPU usage. This includes containers plus overheads.": "引擎总 CPU 用量，包括容器和额外开销。",
  "Engine disk utilization. This includes container data, images, builds, etc.": "引擎磁盘使用量，包括容器数据、镜像、构建等。",
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
  "Tip: use regex like": "提示：可以使用类似这样的正则表达式",
  "Advanced": "高级",
  "These settings are provided for environments with elevated security requirements, such as where local administrative access is prohibited. Changing these options can result in limited functionality or broken integration with other tools.": "这些设置适用于有更高安全要求的环境，例如禁止本地管理员访问的环境。更改这些选项可能导致功能受限，或与其他工具的集成异常。",
  "Choose how to configure the installation of Docker's CLI tools:": "选择 Docker CLI 工具的安装配置方式：",
  "System (requires password)": "系统级（需要密码）",
  "Docker CLI tools are installed under /usr/local/bin.": "Docker CLI 工具安装在 /usr/local/bin 下。",
  "User": "用户级",
  "Docker CLI tools are installed under $HOME/.docker/bin. Note: You need to manually add $HOME/.docker/bin to your PATH.": "Docker CLI 工具安装在 $HOME/.docker/bin 下。注意：你需要手动将 $HOME/.docker/bin 添加到 PATH。",
  "Allow the default Docker socket to be used (requires password)": "允许使用默认 Docker 套接字（需要密码）",
  "Creates /var/run/docker.sock which some third-party clients may use to communicate with Docker Desktop.": "创建 /var/run/docker.sock，某些第三方客户端可能会用它与 Docker Desktop 通信。",
  "Allow privileged port mapping (requires password)": "允许特权端口映射（需要密码）",
  "Starts the privileged helper process which binds privileged ports that are between 1 and 1024.": "启动特权辅助进程，用于绑定 1 到 1024 之间的特权端口。",
  "Docker Model Runner is not enabled": "Docker Model Runner 尚未启用",
  "Enable Docker Model Runner in Settings to pull, run, and manage AI models locally.": "在设置中启用 Docker Model Runner，即可在本地拉取、运行和管理 AI 模型。",
  "AI Settings": "AI 设置",
  "MCP Toolkit": "MCP 工具包",
  "Profiles": "配置文件",
  "Catalog": "目录",
  "Clients": "客户端",
  "OAuth": "OAuth",
  "Search MCP profiles": "搜索 MCP 配置文件",
  "Create a profile": "创建配置文件",
  "Import a profile": "导入配置文件",
  "Add tools to your AI": "给你的 AI 添加工具",
  "Use MCP servers to give AI clients easy access to dev tools, databases, and more. Create profiles to organize your servers and switch between setups for different projects.": "使用 MCP 服务器，让 AI 客户端轻松访问开发工具、数据库等能力。创建配置文件来组织服务器，并在不同项目的配置之间切换。",
  "Start guided tour": "开始引导教程",
  "Or choose a template profile to start:": "也可以选择一个模板配置文件开始：",
  "AI coding": "AI 编程",
  "Import template": "导入模板",
  "Write code faster with Context7 for codebase awareness and Sequential Thinking for structured problem-solving.": "结合 Context7 的代码库感知和 Sequential Thinking 的结构化问题拆解，更快地编写代码。",
  "Dev workflow": "开发工作流",
  "Automate your development cycle: open issues, write code, and update tickets with GitHub and Atlassian.": "自动化你的开发流程：用 GitHub 和 Atlassian 创建 issue、编写代码并更新工单。",
  "Terminal control": "终端控制",
  "Run commands and scripts, manage files, and control your system directly from your AI client.": "直接从 AI 客户端运行命令和脚本、管理文件并控制系统。",
  "New session": "新会话",
  "Session options": "会话选项",
  "hide sessions list": "隐藏会话列表",
  "Sessions": "会话",
  "Detach": "分离",
  "What can I help you with?": "我可以帮你做什么？",
  "Debug containers, write Dockerfiles, scan for vulnerabilities, and more. Pick a suggestion or just type what you need.": "调试容器、编写 Dockerfile、扫描漏洞等。选择一个建议，或直接输入你需要的内容。",
  "Open a project folder": "打开项目文件夹",
  "Get project-aware assistance. I can read your code, write Dockerfiles, and fix errors in context.": "获取理解项目上下文的帮助。我可以读取你的代码、编写 Dockerfile，并结合上下文修复错误。",
  "Select folder": "选择文件夹",
  "TRY ASKING": "试着问",
  "Fix a container error": "修复容器错误",
  "Create a Dockerfile": "创建 Dockerfile",
  "Clean up Docker": "清理 Docker",
  "Security scan": "安全扫描",
  "Start a dev container": "启动开发容器",
  "Explain Docker concepts": "解释 Docker 概念",
  "What should I build, check, or explain?": "你想让我构建、检查或解释什么？",
  "Attach a file": "附加文件",
  "Configure which types of notifications you'll receive inside Docker Desktop.": "配置你将在 Docker Desktop 内接收哪些类型的通知。",
  "These notifications are always enabled": "这些通知始终启用",
  "Docker Desktop errors": "Docker Desktop 错误",
  "New releases": "新版本发布",
  "Status updates on tasks and processes": "任务和进程状态更新",
  "Recommendations from Docker": "Docker 推荐",
  "Docker announcements": "Docker 公告",
  "Docker surveys": "Docker 调查",
  "File sharing": "文件共享",
  "Proxies": "代理",
  "Network": "网络",
  "Resource Allocation": "资源分配",
  "CPU limit:": "CPU 限制：",
  "Memory limit:": "内存限制：",
  "Swap:": "交换空间：",
  "Disk usage limit:": "磁盘使用上限：",
  "Limit to the amount of disk space the engine can use, including overheads. Docker will allocate and free space on demand, but will not exceed this limit.": "限制引擎可使用的磁盘空间总量，包括额外开销。Docker 会按需分配和释放空间，但不会超过此上限。",
  "Disk image location": "磁盘镜像位置",
  "Browse": "浏览",
  "Enable Resource Saver": "启用资源节省器",
  "Reduces CPU and memory utilization when no containers are running. Exit from Resource Saver mode happens automatically when containers are started.": "没有容器运行时降低 CPU 和内存占用。启动容器时会自动退出资源节省模式。",
  "Use the slider to set the duration of time between no containers running and Docker Desktop entering Resource Saver mode.": "使用滑块设置从没有容器运行到 Docker Desktop 进入资源节省模式之间的等待时间。",
  "Configure the way Docker containers interact with the network": "配置 Docker 容器与网络交互的方式",
  "Docker subnet": "Docker 子网",
  "default:": "默认：",
  "Use kernel networking for UDP": "对 UDP 使用内核网络",
  "Use a more efficient kernel networking path for UDP. This may not be compatible with your VPN software.": "对 UDP 使用更高效的内核网络路径。这可能与你的 VPN 软件不兼容。",
  "Enable host networking": "启用主机网络",
  "Port binding behavior": "端口绑定行为",
  "Open (Default)": "开放（默认）",
  "Controls how ports are bound to containers, either making them available on the local network (default) or only on localhost.": "控制端口如何绑定到容器：可以在本地网络中可用（默认），也可以仅在 localhost 上可用。",
  "Default networking mode": "默认网络模式",
  "IPv4 only": "仅 IPv4",
  "Inhibit DNS resolution for IPv4 / IPv6": "抑制 IPv4 / IPv6 DNS 解析",
  "Based on selected network mode": "基于所选网络模式",
  "Auto (recommended)": "自动（推荐）",
  "about detailed behavior, and enterprise configuration options.": "了解详细行为和企业配置选项。",
  "BETA": "Beta",
  "Try asking": "试着问",
  "Selected builder": "当前构建器",
  "Import builds": "导入构建",
  "Builder settings": "构建器设置",
  "Build history": "构建历史",
  "Active builds": "活动构建",
  "Open builds toolbar": "打开构建工具栏",
  "Show only my builds": "仅显示我的构建",
  "Builder": "构建器",
  "Duration": "持续时间",
  "Cloud Build User": "云构建用户",
  "Sort": "排序",
  "No build record found": "未找到构建记录",
  "If you can't see your builds here make sure your builder instances are running.": "如果这里看不到你的构建，请确认构建器实例正在运行。",
  "Rows per page:": "每页行数：",
  "Go to previous page": "上一页",
  "Go to next page": "下一页",
  "Determines which terminal is launched when opening the terminal from a container.": "决定从容器打开终端时启动哪个终端。",
  "Enable Docker terminal": "启用 Docker 终端",
  "Customize terminal appearance": "自定义终端外观",
  "Font family": "字体系列",
  "Default": "默认",
  "Font size": "字体大小",
  "Enable Docker Debug by default": "默认启用 Docker Debug",
  "Include VM in Time Machine backups": "将虚拟机包含在 Time Machine 备份中",
  "Use containerd for pulling and storing images": "使用 containerd 拉取和存储镜像",
  "The containerd image store enables native support for multi-platform images, attestations, Wasm, and more.": "containerd 镜像存储原生支持多平台镜像、证明、Wasm 等能力。",
  "Virtual Machine Options": "虚拟机选项",
  "Choose Virtual Machine Manager (VMM)": "选择虚拟机管理器（VMM）",
  "Apple Virtualization framework": "Apple 虚拟化框架",
  "Use Docker VMM or Apple Virtualization framework for creating and managing Docker Desktop Linux VM in macOS 12.5 and above. Docker VMM is our most performant option for Apple Silicon Macs.": "在 macOS 12.5 及以上版本中，使用 Docker VMM 或 Apple 虚拟化框架创建和管理 Docker Desktop Linux 虚拟机。Docker VMM 是 Apple Silicon Mac 上性能最好的选项。",
  "Use Rosetta for x86_64/amd64 emulation on Apple Silicon": "在 Apple Silicon 上使用 Rosetta 模拟 x86_64/amd64",
  "Turns on Rosetta to accelerate x86_64/amd64 binary emulation on Apple Silicon.": "启用 Rosetta，以加速 Apple Silicon 上的 x86_64/amd64 二进制模拟。",
  "Note: You must have  Apple Virtualization framework enabled.": "注意：你必须启用 Apple 虚拟化框架。",
  "Note: You must have Apple Virtualization framework enabled.": "注意：你必须启用 Apple 虚拟化框架。",
  "Choose file sharing implementation for your containers": "选择容器的文件共享实现",
  "osxfs (Legacy)": "osxfs（旧版）",
  "VirtioFS brings improved I/O performance for operations on bind mounts.": "VirtioFS 可提升绑定挂载操作的 I/O 性能。",
  "It can only be used with Docker VMM or Apple Virtualization framework.": "它只能与 Docker VMM 或 Apple 虚拟化框架一起使用。",
  "Send usage statistics": "发送使用统计信息",
  "Send error reports, system version and language as well as Docker Desktop lifecycle information (e.g., starts, stops, resets).": "发送错误报告、系统版本和语言，以及 Docker Desktop 生命周期信息（例如启动、停止、重置）。",
  "Use Enhanced Container Isolation": "使用增强型容器隔离",
  "Enhance security by preventing containers from breaching the Linux VM.": "通过防止容器突破 Linux 虚拟机来增强安全性。",
  "Show CLI Hints": "显示 CLI 提示",
  "Get CLI hints and tips when running Docker commands in the CLI.": "在 CLI 中运行 Docker 命令时获取提示和技巧。",
  "Enable Scout image analysis": "启用 Scout 镜像分析",
  "Enable background Scout SBOM indexing": "启用后台 Scout SBOM 索引",
  "Automatically start Scout SBOM indexing of newly built or pulled images, and when an image is inspected.": "对新构建或拉取的镜像，以及被检查的镜像，自动启动 Scout SBOM 索引。",
  "Automatically check configuration": "自动检查配置",
  "Enable Kubernetes": "启用 Kubernetes",
  "Start a Kubernetes single or multi-node cluster when starting Docker Desktop.": "Docker Desktop 启动时启动一个 Kubernetes 单节点或多节点集群。",
  "Settings for beta AI features can be found": "Beta AI 功能的设置可以在这里找到",
  "here": "这里",
  "Enable Gordon": "启用 Gordon",
  "Enable the Gordon AI agent, including the \"Gordon\" interface, in Docker Desktop and CLI.": "在 Docker Desktop 和 CLI 中启用 Gordon AI 助手，包括“Gordon”界面。",
  "Legal terms": "法律条款",
  "Enable Docker Model Runner": "启用 Docker Model Runner",
  "Enables the Docker Model Runner, which allows you to run AI models on your machine.": "启用 Docker Model Runner，让你可以在本机运行 AI 模型。",
  "configuration file": "配置文件",
  "The default builder used when you start a build.": "启动构建时默认使用的构建器。",
  "Available builders": "可用构建器",
  "Inspect and manage your builders.": "检查并管理你的构建器。",
  "Running": "运行中",
  "Paused": "已暂停",
  "Note: You must have": "注意：你必须启用",
  "enabled.": "。",
  "Beta features are work in progress and subject to change. Use them to explore and influence upcoming functionality.": "Beta 功能仍在开发中，可能会发生变化。你可以用它们探索并影响即将推出的功能。",
  "Enable Docker MCP Toolkit": "启用 Docker MCP 工具包",
  "Enable \"MCP Toolkit\" feature in Docker Desktop and CLI.": "在 Docker Desktop 和 CLI 中启用“MCP 工具包”功能。",
  "Enable Wasm, requires the containerd image store": "启用 Wasm，需要 containerd 镜像存储",
  "containerd image store": "containerd 镜像存储",
  "Installs runtimes that lets you run": "安装运行时，以便运行",
  "Wasm workloads": "Wasm 工作负载",
  "Check back for more features soon, or sign up for our": "稍后回来查看更多功能，或注册我们的",
  "Developer Preview Program": "开发者预览计划",
  "These directories (and their subdirectories) can be bind mounted into Docker containers. You can check the documentation for more details.": "这些目录（及其子目录）可以绑定挂载到 Docker 容器中。你可以查看文档了解更多详情。",
  "Synchronized file shares": "同步文件共享",
  "New": "新",
  "These locations will be made available to containers using synchronized caches of host filesystem contents. Available with Pro, Team, and Business subscriptions.": "这些位置将通过主机文件系统内容的同步缓存提供给容器使用。Pro、Team 和 Business 订阅可用。",
  "Reduced build times": "缩短构建时间",
  "Faster Git operations": "更快的 Git 操作",
  "Recommended for PHP and JS": "推荐用于 PHP 和 JS",
  "Upgrade to Pro, Team, or Business to use synchronized file shares.": "升级到 Pro、Team 或 Business 以使用同步文件共享。",
  "Virtual file shares": "虚拟文件共享",
  "These locations will be made available to containers using virtual filesystems (such as VirtioFS), which don't require the use of additional VM storage.": "这些位置将通过虚拟文件系统（如 VirtioFS）提供给容器使用，无需额外占用虚拟机存储。",
  "Configure proxy settings for Docker Desktop. The supported proxies are HTTP/HTTPS and SOCKS5.": "配置 Docker Desktop 的代理设置。支持的代理类型包括 HTTP/HTTPS 和 SOCKS5。",
  "Docker Desktop proxy": "Docker Desktop 代理",
  "Used for purposes like signing in, pulling or pushing images, or reporting error diagnostics.": "用于登录、拉取或推送镜像、上报错误诊断等用途。",
  "Proxy mode": "代理模式",
  "System proxy": "系统代理",
  "No proxy": "不使用代理",
  "Manual configuration": "手动配置",
  "Container proxy": "容器代理",
  "容器 proxy": "容器代理",
  "Used for outward-bound traffic from running containers.": "用于正在运行的容器向外访问的流量。",
  "Same as host proxy": "与主机代理相同",
  "Custom catalogs": "自定义目录",
  "Add servers from your custom catalogs.": "从你的自定义目录添加服务器。",
  "No custom catalogs": "没有自定义目录",
  "Import catalog": "导入目录",
  "Import a catalog": "导入目录",
  "导入 catalog": "导入目录",
  "learn how to create one": "了解如何创建一个",
  "Import a catalog or learn how to create one": "导入目录，或了解如何创建一个",
  "导入 a catalog or learn how to create one": "导入目录，或了解如何创建一个",
  "Docker MCP catalog": "Docker MCP 目录",
  "Add servers from the Docker MCP catalog.": "从 Docker MCP 目录添加服务器。",
  "Add servers from the Docker MCP 目录.": "从 Docker MCP 目录添加服务器。",
  "Contribute": "参与贡献",
  "Search servers": "搜索服务器",
  "搜索 servers": "搜索服务器",
  "sorting": "排序",
  "Known publisher": "已知发布者",
  "KNOWN PUBLISHER": "已知发布者",
  "Created by affiliated contributors.": "由关联贡献者创建。",
  "Known publisher: Created by affiliated contributors.": "已知发布者：由关联贡献者创建。",
  "Known publisher: 创建时间 by affiliated contributors.": "已知发布者：由关联贡献者创建。",
  "Pulls": "拉取次数",
  "Tools": "工具",
  "Configure MCP clients to run your AI workloads": "配置 MCP 客户端来运行你的 AI 工作负载",
  "or": "或",
  "You can connect with one of our preconfigured MCP clients:": "你可以连接以下预配置的 MCP 客户端之一：",
  "Use an OAuth provider to securely authenticate to MCP servers with existing credentials.": "使用 OAuth 提供商，通过现有凭据安全地认证到 MCP 服务器。",
  "Search OAuth providers": "搜索 OAuth 提供商",
  "Authorize MCP Toolkit to access your GitHub account": "授权 MCP 工具包访问你的 GitHub 账户",
  "Authorize MCP 工具包 to access your GitHub account": "授权 MCP 工具包访问你的 GitHub 账户",
  "Authorize": "授权",
  "Restart Docker Desktop": "重启 Docker Desktop",
  "All containers and settings are preserved.": "所有容器和设置都会保留。",
  "Support": "支持",
  "Get help with Docker Desktop.": "获取 Docker Desktop 帮助。",
  "Reset Kubernetes cluster": "重置 Kubernetes 集群",
  "重置 Kubernetes cluster": "重置 Kubernetes 集群",
  "All stacks and Kubernetes resources are deleted.": "所有 Stack 和 Kubernetes 资源都会被删除。",
  "Clean / Purge data": "清理 / 清除数据",
  "This solves problems with disk corruption or Docker Engine not booting etc.": "这可解决磁盘损坏、Docker 引擎无法启动等问题。",
  "This solves problems with disk corruption or Docker 引擎 not booting etc.": "这可解决磁盘损坏、Docker 引擎无法启动等问题。",
  "Reset to factory defaults": "重置为出厂默认设置",
  "重置 to factory defaults": "重置为出厂默认设置",
  "All settings and data will be removed.": "所有设置和数据都会被移除。",
  "Uninstall Docker Desktop": "卸载 Docker Desktop",
  "We're sorry to see you go. This completely uninstalls Docker Desktop.": "很遗憾你要离开。这会完全卸载 Docker Desktop。",
  "Search the Web for pages, images, news, videos, and more using the Brave Search API.": "使用 Brave Search API 搜索网页、图片、新闻、视频等。",
  "搜索 the Web for pages, images, news, videos, and more using the Brave 搜索 API.": "使用 Brave Search API 搜索网页、图片、新闻、视频等。",
  "Search, update, manage files and run terminal commands with AI.": "使用 AI 搜索、更新、管理文件并运行终端命令。",
  "搜索, update, manage files and run terminal commands with AI.": "使用 AI 搜索、更新、管理文件并运行终端命令。",
  "Local filesystem access with configurable allowed paths.": "可配置允许路径的本地文件系统访问。",
  "本地 filesystem access with configurable allowed paths.": "可配置允许路径的本地文件系统访问。",
  "These directories (and their subdirectories) can be bind mounted into Docker containers. You can check the": "这些目录（及其子目录）可以绑定挂载到 Docker 容器中。你可以查看",
  "documentation": "文档",
  "for more details.": "了解更多详情。",
  "Upgrade": "升级",
  "to Pro, Team, or Business to use synchronized file shares.": "到 Pro、Team 或 Business 以使用同步文件共享。",
  "or": "或",
  "导入目录 or": "导入目录，或",
  "to access your": "访问你的",
  "account": "账户",
  "in use": "已用",
  "Showing 1 item": "显示 1 项",
  "导入目录 or 了解如何创建一个": "导入目录，或了解如何创建一个",
  "Connect your MCP client": "连接你的 MCP 客户端",
  "Set up any MCP client to connect to the MCP Toolkit": "设置任意 MCP 客户端以连接到 MCP 工具包",
  "Set up any MCP client to connect to the MCP 工具包": "设置任意 MCP 客户端以连接到 MCP 工具包",
  "Connect to": "连接到",
  "授权 MCP 工具包 to access your GitHub account": "授权 MCP 工具包访问你的 GitHub 账户",
  "授权 MCP 工具包 to access your  GitHub  account": "授权 MCP 工具包访问你的 GitHub 账户",
  "Get support": "获取支持",
  "Uninstall": "卸载",
  "No OAuth providers found": "未找到 OAuth 提供商",
  "There are no results for your search.": "没有符合搜索条件的结果。",
  "No OAuth providers found There are no results for your search.": "未找到 OAuth 提供商。没有符合搜索条件的结果。",
  "未找到 OAuth 提供商 There are no results for your search.": "未找到 OAuth 提供商。没有符合搜索条件的结果。",
  "No new notifications": "没有新通知",
  "No notifications": "没有通知",
  "You're all caught up": "暂无待处理通知",
  "You’re all caught up": "暂无待处理通知",
  "All caught up": "已全部处理",
  "Notification center": "通知中心",
  "Mark all as read": "全部标记为已读",
  "Clear notifications": "清除通知",
  "Clear all notifications": "清除所有通知",
  "Clear all notifications?": "要清除所有通知吗？",
  "Unread": "未读",
  "Read": "已读",
  "All notifications": "所有通知",
  "New notifications": "新通知",
  "Dismiss notification": "关闭通知",
  "Dismiss all": "全部关闭",
  "See all notifications": "查看所有通知",
  "No unread notifications": "没有未读通知",
  "There are no notifications yet.": "目前还没有通知。",
  "Close notifications": "关闭通知",
  "关闭 notifications": "关闭通知",
  "Containers can use volumes to store data": "容器可以使用卷存储数据",
  "容器 can use volumes to store data": "容器可以使用卷存储数据",
  "All data in a container is lost once it is removed. Containers use volumes to persist data.": "容器被删除后，其中所有数据都会丢失。容器使用卷来持久化数据。",
  "All data in a container is lost once it is removed. 容器 use volumes to persist data.": "容器被删除后，其中所有数据都会丢失。容器使用卷来持久化数据。",
  "Create a volume": "创建卷",
  "创建 a volume": "创建卷",
  "Multi-container applications": "多容器应用",
  "Persist your data between containers": "在容器之间持久化数据",
  "Playwright MCP server.": "Playwright MCP 服务器。",
  "Fetches a URL from the internet and extracts its contents as markdown.": "从互联网获取 URL，并将其内容提取为 Markdown。",
  "Community-maintained server for DuckDuckGo search. Not published by or affiliated with DuckDuckGo.": "由社区维护的 DuckDuckGo 搜索服务器。并非由 DuckDuckGo 发布，也不隶属于 DuckDuckGo。",
  "Time and timezone conversion capabilities.": "时间和时区转换能力。",
  "MCP server for Grafana.": "Grafana 的 MCP 服务器。",
  "Interact with SonarQube Cloud, Server and Community build over the web API. Analyze code to identify quality and security issues.": "通过 Web API 与 SonarQube Cloud、Server 和 Community Build 交互。分析代码以识别质量和安全问题。",
  "Knowledge graph-based persistent memory system.": "基于知识图谱的持久记忆系统。",
  "Context7 Platform -- Up-to-date code docs for LLMs and AI code editors.": "Context7 平台——为 LLM 和 AI 代码编辑器提供最新代码文档。",
  "Context7 Platform -- Up-to-date code 文档 for LLMs and AI code editors.": "Context7 平台——为 LLM 和 AI 代码编辑器提供最新代码文档。",
  "Dynamic and reflective problem-solving through thought sequences.": "通过思维序列进行动态、反思式问题解决。",
  "Interact with Slack Workspaces over the Slack API.": "通过 Slack API 与 Slack 工作区交互。",
  "This MCP Server allows interaction with the Dynatrace observability platform, brining real-time observability data directly into your development workflow.": "此 MCP 服务器可与 Dynatrace 可观测性平台交互，将实时可观测性数据直接带入你的开发工作流。",
  "Retrieves transcripts for given YouTube video URLs.": "获取指定 YouTube 视频 URL 的字幕文本。",
  "Browser automation and web scraping using Puppeteer.": "使用 Puppeteer 进行浏览器自动化和网页抓取。",
  "Official Notion MCP Server.": "官方 Notion MCP 服务器。",
  "A Model Context Protocol (MCP) server that retrieves information from Wikipedia to provide context to LLMs.": "一个从 Wikipedia 检索信息、为 LLM 提供上下文的 Model Context Protocol (MCP) 服务器。",

}));

const patternDictionary = [
  [/^Version (.+) is available to download$/i, "版本 $1 可供下载"],
  [/^Estimated time: (.+)$/i, "预计时间：$1"],
  [/^(\d+)\s*mins$/i, "$1 分钟"],
  [/^(\d+)\s+images?$/i, "$1 个镜像"],
  [/^(\d+)\s+days?\s+ago$/i, "$1 天前"],
  [/^Last refresh:\s*(.+)$/i, "上次刷新：$1"],
  [/^(.+?)\s+\/\s+(.+?)\s+in use\s+(\d+)\s+images?$/i, "已用 $1 / $2，共 $3 个镜像"],
  [/^Showing\s+(\d+)\s+items?$/i, "显示 $1 项"],
  [/^.*Detected shell:\s*(.+)$/i, "检测到的 Shell：$1"],
  [/^Disk: (.+) used \(limit (.+)\)$/i, "磁盘：已用 $1（上限 $2）"],
  [/^running in Resource Saver mode$/i, "正在资源节省模式下运行"],
  [/^Add search filter \(supports regex like \"(.+)\"\)$/i, "添加搜索筛选（支持类似 \"$1\" 的正则）"],
  [new RegExp("^Catalog \\((\\d+)\\)$"), "目录 ($1)"],
  [new RegExp("^Detected shell:\\s*(.+)$"), "检测到的 Shell：$1"],
  [new RegExp("^default:\\s*(.+)$"), "默认：$1"],
  [new RegExp("^CPU limit:\\s*(.+)$"), "CPU 限制：$1"],
  [new RegExp("^Memory limit:\\s*(.+)$"), "内存限制：$1"],
  [new RegExp("^Swap:\\s*(.+)$"), "交换空间：$1"],
  [new RegExp("^Disk usage limit:\\s*(.+)$"), "磁盘使用上限：$1"],
  [new RegExp("^Rows per page:\\s*(.+)$"), "每页行数：$1"],
  [new RegExp("^(\\d+)–(\\d+) of (\\d+)$"), "$1-$2，共 $3 条"],
  [new RegExp("^New session (/.+)$"), "新会话 $1"],
  [new RegExp("^Note:\\s*You must have\\s+(.+?)\\s+enabled\\.$"), "注意：你必须启用 $1。"],
  [new RegExp("^(.+?)\\s+Turns on Rosetta to accelerate x86_64/amd64 binary emulation on Apple Silicon\\.$"), "$1。启用 Rosetta，以加速 Apple Silicon 上的 x86_64/amd64 二进制模拟。"],
  [new RegExp("^(\\d+) months? ago$"), "$1 个月前"],
  [new RegExp("^Settings for beta AI features can be found\\s*$"), "Beta AI 功能的设置可以在这里找到"],
  [new RegExp("^Configure the Docker daemon by typing a JSON Docker daemon\\s*(.+?)?\\s*\\.?$"), "通过输入 JSON 格式的 Docker 守护进程配置文件来配置 Docker 守护进程。"],
  [new RegExp("^(\\d+) hours? ago$"), "$1 小时前"],
  [new RegExp("^Last refresh:\\s*(\\d+) hours? ago$"), "上次刷新：$1 小时前"],
  [new RegExp("^上次刷新：\\s*(\\d+) hours? ago$"), "上次刷新：$1 小时前"],
  [new RegExp("^(.+?) / (.+?) in use (\\d+) images?\\s+上次刷新：(.+)$"), "已用 $1 / $2，$3 个镜像，上次刷新：$4"],
  [new RegExp("^Showing\\s+(\\d+)\\s+item$"), "显示 $1 项"],
  [new RegExp("^Set up (.+?) to connect to the MCP Toolkit$"), "设置 $1 以连接到 MCP 工具包"],
  [new RegExp("^Set up (.+?) to connect to the MCP 工具包$"), "设置 $1 以连接到 MCP 工具包"],
  [new RegExp("^授权 MCP 工具包 to access your\\s+(.+?)\\s+account$"), "授权 MCP 工具包访问你的 $1 账户"],

];

const ATTR_KEYS = ["title", "aria-label", "placeholder", "alt", "value", "data-tooltip", "data-title"];
const IGNORE_TAGS = new Set(["SCRIPT", "STYLE", "NOSCRIPT", "CODE", "PRE", "SVG", "PATH", "CANVAS", "VIDEO", "AUDIO", "IFRAME", "OBJECT", "EMBED"]);
const QUEUE_LIMIT = 128;
const TARGET_TEXT_CONTENT_FIXES = new Map([
  ["There are no results for your search.", "没有符合搜索条件的结果。"],
  ["No OAuth providers found There are no results for your search.", "未找到 OAuth 提供商。没有符合搜索条件的结果。"],
  ["未找到 OAuth 提供商 There are no results for your search.", "未找到 OAuth 提供商。没有符合搜索条件的结果。"],
  ["Showing 1 item", "显示 1 项"],
]);

const shouldSkipNode = (node) => {
  if (!node) return true;
  if (node.nodeType !== Node.ELEMENT_NODE) return false;
  return IGNORE_TAGS.has(node.tagName);
};

const normalize = (value) => {
  if (!value || typeof value !== "string") return "";
  return value.replace(/\u00a0/g, " ").replace(/\s+/g, " ").trim();
};

const preserveOuterWhitespace = (source, translated) => {
  const leading = source.match(/^\s*/)?.[0] || "";
  const trailing = source.match(/\s*$/)?.[0] || "";
  return `${leading}${translated}${trailing}`;
};

const segmentKeys = Array.from(dictionary.keys())
  .filter((key) => normalize(key).length >= 5 && dictionary.get(key) !== key)
  .sort((a, b) => normalize(b).length - normalize(a).length);

const escapeRegExp = (value) => value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
const isAsciiWordChar = (value) => /^[A-Za-z0-9_]$/.test(value || "");

const translateSegments = (value) => {
  let result = value;
  for (const key of segmentKeys) {
    const normalizedKey = normalize(key);
    const translated = dictionary.get(key);
    if (!normalizedKey || !translated) continue;

    const needsLeadingGuard = isAsciiWordChar(normalizedKey[0]);
    const needsTrailingGuard = isAsciiWordChar(normalizedKey[normalizedKey.length - 1]);
    const pattern = new RegExp(
      `${needsLeadingGuard ? "(^|[^A-Za-z0-9_])" : ""}(${escapeRegExp(normalizedKey)})${needsTrailingGuard ? "(?=$|[^A-Za-z0-9_])" : ""}`,
      "g"
    );

    result = result.replace(pattern, (...args) => {
      const leading = needsLeadingGuard ? args[1] : "";
      return `${leading || ""}${translated}`;
    });
  }
  return result;
};

const translateValue = (value) => {
  const v = normalize(value);
  if (!v) return value;

  const direct = dictionary.get(v);
  if (direct) return preserveOuterWhitespace(value, direct);

  for (const [pattern, replacement] of patternDictionary) {
    if (pattern.test(v)) {
      return preserveOuterWhitespace(value, v.replace(pattern, replacement));
    }
  }

  const segmented = translateSegments(v);
  if (segmented !== v) {
    return preserveOuterWhitespace(value, segmented);
  }

  return value;
};

const applyText = (node) => {
  if (!node || node.nodeType !== Node.TEXT_NODE) return;
  const value = node.nodeValue;
  const translated = translateValue(value);
  if (translated !== value && translated !== value.trim()) {
    node.nodeValue = translated;
  } else if (translated !== value && translated === value.trim()) {
    node.nodeValue = translated;
  }
};

const applyAttributes = (element) => {
  if (!element || element.nodeType !== Node.ELEMENT_NODE) return;
  for (const key of ATTR_KEYS) {
    if (!element.getAttribute) continue;
    const current = element.getAttribute(key);
    if (!current) continue;
    const translated = translateValue(current);
    if (translated !== current) {
      element.setAttribute(key, translated);
    }
  }
};

const applyAttributesDeep = (root) => {
  if (!root || root.nodeType !== Node.ELEMENT_NODE) return;
  applyAttributes(root);

  const selector = ATTR_KEYS.map((key) => `[${key}]`).join(",");
  for (const element of root.querySelectorAll?.(selector) || []) {
    applyAttributes(element);
  }
};

const shouldSkipTargetTextContent = (element) => {
  if (!element || element.nodeType !== Node.ELEMENT_NODE) return true;
  if (shouldSkipNode(element)) return true;
  if (element.isContentEditable) return true;
  if (element.matches?.("button,a,input,textarea,select,[role='button']")) return true;
  if (element.querySelector?.("button,a,input,textarea,select,[role='button'],svg,img")) return true;
  return false;
};

const applyTargetTextContent = (element) => {
  if (shouldSkipTargetTextContent(element)) return;

  const source = element.textContent || "";
  const current = normalize(source);
  if (!current || current.length > 160) return;

  const translated = TARGET_TEXT_CONTENT_FIXES.get(current) || (element.children.length === 0 ? translateValue(source) : null);
  if (translated && translated !== current) {
    element.textContent = translated;
  }
};

const applyTargetTextContentDeep = (root) => {
  if (!root || root.nodeType !== Node.ELEMENT_NODE) return;
  applyTargetTextContent(root);

  for (const element of root.querySelectorAll?.("*") || []) {
    applyTargetTextContent(element);
  }
};

const walkShadowRoots = (root) => {
  if (!root) return;
  if (root.nodeType === Node.ELEMENT_NODE && root.shadowRoot) {
    walkNode(root.shadowRoot);
  }

  const doc = root.ownerDocument || document;
  const walker = doc.createTreeWalker(root, NodeFilter.SHOW_ELEMENT);
  let element;
  while ((element = walker.nextNode())) {
    if (element.shadowRoot) {
      walkNode(element.shadowRoot);
    }
  }
};

const walkNode = (root) => {
  if (!root) return;
  if (root.nodeType === Node.TEXT_NODE) {
    applyText(root);
    return;
  }
  if (shouldSkipNode(root)) return;

  const doc = root.ownerDocument || document;
  const walker = doc.createTreeWalker(
    root,
    NodeFilter.SHOW_TEXT,
    {
      acceptNode: (node) => {
        if (!node.parentElement || shouldSkipNode(node.parentElement)) return NodeFilter.FILTER_REJECT;
        return NodeFilter.FILTER_ACCEPT;
      }
    }
  );

  let node;
  while ((node = walker.nextNode())) {
    applyText(node);
  }

  applyAttributesDeep(root);
  applyTargetTextContentDeep(root);
  walkShadowRoots(root);
};

const pending = new Set();
const addPending = (node) => {
  if (!node) return;
  if (pending.size >= QUEUE_LIMIT) return;
  pending.add(node);
};

let scheduled = false;
const run = () => {
  try {
    if (!document || !document.body) return;
    walkNode(document.body);
  } catch (_error) {
    // avoid any unexpected exception breaking page bootstrap
  }
};

const drainQueue = () => {
  scheduled = false;
  let count = 0;
  for (const node of Array.from(pending)) {
    pending.delete(node);
    walkNode(node);
    count += 1;
    if (count >= QUEUE_LIMIT) break;
  }

  if (pending.size > 0) {
    schedule();
  }
};

const schedule = () => {
  if (scheduled) return;
  scheduled = true;
  window.requestAnimationFrame(drainQueue);
};

const observer = new MutationObserver((mutations) => {
  for (const mutation of mutations) {
    if (mutation.type === "childList") {
      mutation.addedNodes.forEach(addPending);
    }
    if (mutation.type === "characterData" && mutation.target) {
      addPending(mutation.target);
    }
  }
  schedule();
});

const boot = () => {
  if (!document.body) return;
  const safeGuard = document.querySelector("meta[name='docker-cn-patch-disabled']");
  if (safeGuard || localStorage.getItem("docker-cn-patch-disabled") === "1") {
    return;
  }

  run();
  [100, 500, 1000, 2000, 5000, 10000].forEach((delay) => {
    window.setTimeout(run, delay);
  });
  window.addEventListener("hashchange", run);
  window.addEventListener("popstate", run);
  window.addEventListener("focus", run);
  window.setInterval(run, 1500);
  observer.observe(document.body, {
    childList: true,
    subtree: true,
    characterData: true
  });
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", boot, { once: true });
} else {
  boot();
}

window.DockerDesktopCNPatch = { run, walkNode, dictionary, translateValue };
})();
