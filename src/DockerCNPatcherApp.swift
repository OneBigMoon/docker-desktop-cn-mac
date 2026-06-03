import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private var statusLabel: NSTextField!
    private var detailLabel: NSTextField!
    private var progress: NSProgressIndicator!
    private var logView: NSTextView!
    private var installButton: NSButton!
    private var restoreButton: NSButton!
    private var backupButton: NSButton!
    private var logButton: NSButton!
    private var currentProcess: Process?
    private var lineBuffer = ""
    private var logFileURL: URL?
    private var mirrorOutputToLog = false
    private var tailTimer: Timer?
    private var tailOffset: UInt64 = 0
    private var lastStage = "准备就绪"
    private var terminalRunActive = false
    private let parseQueue = DispatchQueue(label: "com.onebigmoon.docker-cn-patcher.output")
    private let dockerAppPath = "/Applications/Docker.app"

    private var patcherDir: URL? {
        Bundle.main.resourceURL?.appendingPathComponent("patcher", isDirectory: true)
    }

    private var installScript: URL? {
        patcherDir?.appendingPathComponent("install.sh")
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        buildWindow()
        refreshInitialState()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    private func buildWindow() {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 780, height: 590),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Docker Desktop 汉化补丁"
        window.isReleasedWhenClosed = false

        let root = NSView()
        root.wantsLayer = true
        root.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        window.contentView = root

        let title = makeLabel("Docker Desktop 汉化补丁", size: 24, weight: .bold)
        let subtitle = makeLabel("先备份原始 Docker，再注入中文补丁；安装时会请求管理员权限，失败会自动回退，也支持手动恢复原始 Docker。", size: 13, color: .secondaryLabelColor)

        statusLabel = makeLabel("准备就绪", size: 16, weight: .semibold)
        detailLabel = makeLabel("目标：\(dockerAppPath)", size: 12, color: .secondaryLabelColor)

        progress = NSProgressIndicator()
        progress.minValue = 0
        progress.maxValue = 100
        progress.doubleValue = 0
        progress.isIndeterminate = false
        progress.controlSize = .large
        progress.translatesAutoresizingMaskIntoConstraints = false

        installButton = NSButton(title: "安装 / 重新汉化", target: self, action: #selector(installPatch))
        installButton.bezelStyle = .rounded
        installButton.keyEquivalent = "\r"

        restoreButton = NSButton(title: "恢复原始 Docker", target: self, action: #selector(restoreLatest))
        restoreButton.bezelStyle = .rounded

        backupButton = NSButton(title: "打开备份目录", target: self, action: #selector(openBackups))
        backupButton.bezelStyle = .rounded

        logButton = NSButton(title: "打开日志", target: self, action: #selector(openLog))
        logButton.bezelStyle = .rounded
        logButton.isEnabled = false

        let buttonStack = NSStackView(views: [installButton, restoreButton, backupButton, logButton])
        buttonStack.orientation = .horizontal
        buttonStack.spacing = 12
        buttonStack.alignment = .centerY
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        let logScroll = NSScrollView()
        logScroll.hasVerticalScroller = true
        logScroll.borderType = .lineBorder
        logScroll.translatesAutoresizingMaskIntoConstraints = false

        logView = NSTextView()
        logView.isEditable = false
        logView.isSelectable = true
        logView.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        logView.textColor = .labelColor
        logView.backgroundColor = NSColor.textBackgroundColor
        logView.textContainerInset = NSSize(width: 10, height: 10)
        logScroll.documentView = logView

        let views: [NSView] = [title, subtitle, statusLabel, detailLabel, progress, buttonStack, logScroll]
        for view in views {
            root.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: root.topAnchor, constant: 28),
            title.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 28),
            title.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -28),

            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 6),
            subtitle.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            subtitle.trailingAnchor.constraint(equalTo: title.trailingAnchor),

            statusLabel.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 28),
            statusLabel.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: title.trailingAnchor),

            detailLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 6),
            detailLabel.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: title.trailingAnchor),

            progress.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 16),
            progress.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            progress.trailingAnchor.constraint(equalTo: title.trailingAnchor),

            buttonStack.topAnchor.constraint(equalTo: progress.bottomAnchor, constant: 18),
            buttonStack.leadingAnchor.constraint(equalTo: title.leadingAnchor),

            logScroll.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 20),
            logScroll.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            logScroll.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            logScroll.bottomAnchor.constraint(equalTo: root.bottomAnchor, constant: -24),
        ])
    }

    private func makeLabel(_ text: String, size: CGFloat, weight: NSFont.Weight = .regular, color: NSColor = .labelColor) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = NSFont.systemFont(ofSize: size, weight: weight)
        label.textColor = color
        label.lineBreakMode = .byWordWrapping
        label.maximumNumberOfLines = 0
        return label
    }

    private func refreshInitialState() {
        let dockerExists = FileManager.default.fileExists(atPath: dockerAppPath)
        let scriptExists = installScript.map { FileManager.default.fileExists(atPath: $0.path) } ?? false

        if !scriptExists {
            statusLabel.stringValue = "安装器资源不完整"
            detailLabel.stringValue = "未找到内置 install.sh，请重新构建或重新下载补丁包。"
            installButton.isEnabled = false
            restoreButton.isEnabled = false
            appendLog("未找到内置 install.sh")
            return
        }

        if dockerExists {
            let version = dockerVersion() ?? "未知版本"
            let permissionText = "安装时会请求管理员权限"
            detailLabel.stringValue = "目标：\(dockerAppPath)  |  当前版本：\(version)  |  \(permissionText)"
            appendLog("已检测到 Docker Desktop：\(version)")
            appendLog("权限状态：\(permissionText)")
        } else {
            statusLabel.stringValue = "未找到 Docker Desktop"
            detailLabel.stringValue = "请先把 Docker.app 安装到 /Applications。"
            installButton.isEnabled = false
            appendLog("未找到 \(dockerAppPath)")
        }
    }

    private func dockerVersion() -> String? {
        let candidates = [
            "\(dockerAppPath)/Contents/MacOS/Docker Desktop.app/Contents/Info.plist",
            "\(dockerAppPath)/Contents/Info.plist"
        ]

        for path in candidates where FileManager.default.fileExists(atPath: path) {
            if let data = FileManager.default.contents(atPath: path),
               let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
               let dict = plist as? [String: Any],
               let version = dict["CFBundleShortVersionString"] as? String,
               !version.isEmpty {
                return version
            }
        }
        return nil
    }

    private func needsAdminPrivileges() -> Bool {
        let fileManager = FileManager.default
        let candidates = [
            dockerAppPath,
            "\(dockerAppPath)/Contents/MacOS/Docker Desktop.app/Contents/Info.plist",
            "\(dockerAppPath)/Contents/MacOS/Docker Desktop.app/Contents/Resources/app.asar",
            "\(dockerAppPath)/Contents/Info.plist",
            "\(dockerAppPath)/Contents/Resources/app.asar"
        ]

        for path in candidates where fileManager.fileExists(atPath: path) {
            if !fileManager.isWritableFile(atPath: path) {
                return true
            }
        }
        return false
    }

    @objc private func installPatch() {
        runWithPermissionCheck(scriptArguments: ["--app", dockerAppPath, "--no-restart"], initialStatus: "开始安装汉化补丁", initialProgress: 5)
    }

    @objc private func restoreLatest() {
        let alert = NSAlert()
        alert.messageText = "恢复原始 Docker？"
        alert.informativeText = "这会使用最近一次安装前自动创建的备份，恢复 Docker Desktop 的原始 app.asar 和 Info.plist。容器、镜像和 Docker 设置不会被删除。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "恢复原始 Docker")
        alert.addButton(withTitle: "取消")
        if alert.runModal() != .alertFirstButtonReturn {
            return
        }
        runWithPermissionCheck(scriptArguments: ["--restore-latest", "--app", dockerAppPath], initialStatus: "开始恢复原始 Docker", initialProgress: 5)
    }

    private func runWithPermissionCheck(scriptArguments: [String], initialStatus: String, initialProgress: Double) {
        let alert = NSAlert()
        alert.messageText = "需要管理员权限"
        alert.informativeText = "补丁需要写入 /Applications/Docker.app。点击继续后，macOS 会弹出密码框；这是系统授权窗口，密码不会被本工具保存。"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "使用管理员权限继续")
        alert.addButton(withTitle: "取消")
        if alert.runModal() != .alertFirstButtonReturn {
            return
        }
        run(scriptArguments: scriptArguments, initialStatus: initialStatus, initialProgress: initialProgress, privileged: true)
    }

    @objc private func openBackups() {
        let url = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(".docker-desktop-cn-patcher/backups", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        NSWorkspace.shared.open(url)
    }

    @objc private func openLog() {
        guard let url = logFileURL else { return }
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    private func run(scriptArguments: [String], initialStatus: String, initialProgress: Double, privileged: Bool) {
        guard currentProcess == nil && !terminalRunActive else { return }
        guard let script = installScript, let dir = patcherDir else {
            showAlert(title: "安装器资源不完整", message: "未找到内置安装脚本。")
            return
        }

        setBusy(true)
        logView.string = ""
        lineBuffer = ""
        logFileURL = makeLogFileURL()
        logButton.isEnabled = logFileURL != nil
        mirrorOutputToLog = !privileged
        tailOffset = 0
        if let logFileURL {
            FileManager.default.createFile(atPath: logFileURL.path, contents: nil)
            appendLog("日志文件：\(logFileURL.path)")
        }
        setProgress(initialProgress, initialStatus)
        appendLog(privileged ? "将请求 macOS 管理员权限执行。" : "当前用户权限足够，直接执行。")

        let process = Process()
        currentProcess = process

        if privileged {
            guard let logFileURL else {
                showAlert(title: "日志初始化失败", message: "无法创建日志文件。")
                currentProcess = nil
                setBusy(false)
                return
            }
            process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
            process.arguments = ["-e", privilegedAppleScript(script: script, dir: dir, arguments: scriptArguments, logFile: logFileURL)]
            startLogTail()
        } else {
            process.executableURL = URL(fileURLWithPath: "/bin/bash")
            process.arguments = [script.path] + scriptArguments
            process.currentDirectoryURL = dir
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
                let data = handle.availableData
                guard !data.isEmpty, let text = String(data: data, encoding: .utf8) else { return }
                self?.consumeOutput(text)
            }
        }

        var environment = ProcessInfo.processInfo.environment
        environment["DOCKER_CN_PATCHER_PROGRESS"] = "1"
        environment["PATH"] = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        process.environment = environment

        process.terminationHandler = { [weak self] proc in
            self?.parseQueue.async {
                guard let self else { return }
                DispatchQueue.main.async {
                    self.tailLogOnce()
                    self.stopLogTail()
                }

                let remaining = self.lineBuffer
                self.lineBuffer = ""
                if !remaining.isEmpty {
                    DispatchQueue.main.async { self.handleLine(remaining) }
                }

                DispatchQueue.main.async {
                    self.currentProcess = nil
                    self.setBusy(false)
                    if proc.terminationStatus == 0 {
                        self.setProgress(100, "完成")
                        self.appendLog("完成。")
                        self.refreshInitialState()
                    } else {
                        self.statusLabel.stringValue = "失败：\(self.lastStage)"
                        self.appendLog("进程退出码：\(proc.terminationStatus)")
                        self.showAlert(title: "操作失败", message: self.failureHint(exitCode: proc.terminationStatus))
                    }
                }
            }
        }

        do {
            try process.run()
        } catch {
            currentProcess = nil
            setBusy(false)
            stopLogTail()
            showAlert(title: "启动失败", message: error.localizedDescription)
        }
    }

    private func makeLogFileURL() -> URL? {
        let dir = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Logs/DockerCN-Patcher", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd-HHmmss"
            return dir.appendingPathComponent("install-\(formatter.string(from: Date())).log")
        } catch {
            return nil
        }
    }

    private func privilegedAppleScript(script: URL, dir: URL, arguments: [String], logFile: URL) -> String {
        let commandParts = [
            "cd \(shellQuote(dir.path))",
            "export DOCKER_CN_PATCHER_PROGRESS=1",
            "export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
            "/bin/bash \(shellQuote(script.path)) \(arguments.map(shellQuote).joined(separator: " ")) >> \(shellQuote(logFile.path)) 2>&1"
        ]
        let command = commandParts.joined(separator: " && ")
        return "do shell script \(appleScriptString(command)) with administrator privileges"
    }

    private func runViaTerminal(script: URL, dir: URL, arguments: [String], logFile: URL) {
        terminalRunActive = true
        startLogTail()
        appendLog("Terminal 会打开一个临时窗口执行安装命令；GUI 会继续显示进度。")

        let launcher = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("docker-cn-patcher-\(UUID().uuidString).sh")
        let adminScript = privilegedAppleScript(script: script, dir: dir, arguments: arguments, logFile: logFile)
        let launcherBody = """
        #!/usr/bin/env bash
        set +e
        LOG=\(shellQuote(logFile.path))
        echo "::progress::8::等待管理员授权" >> "$LOG"
        /usr/bin/osascript -e \(shellQuote(adminScript))
        STATUS=$?
        echo "::terminal-exit::$STATUS" >> "$LOG"
        rm -f \(shellQuote(launcher.path))
        exit "$STATUS"
        """

        do {
            try launcherBody.write(to: launcher, atomically: true, encoding: .utf8)
            try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: launcher.path)
        } catch {
            terminalRunActive = false
            stopLogTail()
            setBusy(false)
            showAlert(title: "启动失败", message: "无法创建临时安装脚本：\(error.localizedDescription)")
            return
        }

        let terminalCommand = "/bin/bash \(shellQuote(launcher.path)); exit"
        let osa = """
        tell application "Terminal"
          activate
          do script \(appleScriptString(terminalCommand))
        end tell
        """

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", osa]
        process.terminationHandler = { [weak self] proc in
            if proc.terminationStatus != 0 {
                DispatchQueue.main.async {
                    guard let self else { return }
                    self.terminalRunActive = false
                    self.stopLogTail()
                    self.setBusy(false)
                    self.statusLabel.stringValue = "无法打开 Terminal"
                    self.showAlert(title: "启动失败", message: "无法通过 Terminal 启动安装命令。")
                }
            }
        }

        do {
            try process.run()
        } catch {
            terminalRunActive = false
            stopLogTail()
            setBusy(false)
            showAlert(title: "启动失败", message: error.localizedDescription)
        }
    }

    private func shellQuote(_ value: String) -> String {
        "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }

    private func appleScriptString(_ value: String) -> String {
        "\"" + value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n") + "\""
    }

    private func consumeOutput(_ text: String) {
        if mirrorOutputToLog {
            appendRawOutputToLog(text)
        }

        parseQueue.async { [weak self] in
            guard let self else { return }
            self.lineBuffer += text
            let parts = self.lineBuffer.components(separatedBy: .newlines)
            self.lineBuffer = parts.last ?? ""
            for line in parts.dropLast() {
                DispatchQueue.main.async { self.handleLine(line) }
            }
        }
    }

    private func appendRawOutputToLog(_ text: String) {
        guard let logFileURL, let data = text.data(using: .utf8) else { return }
        if let handle = try? FileHandle(forWritingTo: logFileURL) {
            do {
                try handle.seekToEnd()
                try handle.write(contentsOf: data)
            } catch {
                return
            }
            try? handle.close()
        }
    }

    private func startLogTail() {
        stopLogTail()
        tailTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { [weak self] _ in
            self?.tailLogOnce()
        }
    }

    private func stopLogTail() {
        tailTimer?.invalidate()
        tailTimer = nil
    }

    private func tailLogOnce() {
        guard let logFileURL else { return }
        guard let handle = try? FileHandle(forReadingFrom: logFileURL) else { return }
        defer { try? handle.close() }
        do {
            try handle.seek(toOffset: tailOffset)
            let data = try handle.readToEnd() ?? Data()
            guard !data.isEmpty else { return }
            tailOffset += UInt64(data.count)
            if let text = String(data: data, encoding: .utf8) {
                consumeOutput(text)
            }
        } catch {
            return
        }
    }

    private func handleLine(_ line: String) {
        if line.hasPrefix("::terminal-exit::") {
            let value = String(line.dropFirst("::terminal-exit::".count))
            let status = Int32(value.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 1
            terminalRunActive = false
            stopLogTail()
            setBusy(false)
            tailLogOnce()

            if status == 0 {
                setProgress(100, "完成")
                appendLog("完成。")
                refreshInitialState()
            } else {
                statusLabel.stringValue = "失败：\(lastStage)"
                appendLog("进程退出码：\(status)")
                showAlert(title: "操作失败", message: failureHint(exitCode: status))
            }
            return
        }

        if line.hasPrefix("::progress::") {
            let payload = String(line.dropFirst("::progress::".count))
            let parts = payload.components(separatedBy: "::")
            if parts.count >= 2, let value = Double(parts[0]) {
                setProgress(value, parts.dropFirst().joined(separator: "::"))
                return
            }
        }
        appendLog(line)
    }

    private func setProgress(_ value: Double, _ status: String) {
        progress.doubleValue = max(0, min(100, value))
        statusLabel.stringValue = status
        lastStage = status
        appendLog("[\(Int(progress.doubleValue))%] \(status)")
    }

    private func appendLog(_ line: String) {
        guard !line.isEmpty else { return }
        let text = logView.string.isEmpty ? line : "\(logView.string)\n\(line)"
        logView.string = text
        logView.scrollToEndOfDocument(nil)
    }

    private func setBusy(_ busy: Bool) {
        installButton.isEnabled = !busy
        restoreButton.isEnabled = !busy
        backupButton.isEnabled = !busy
        logButton.isEnabled = !busy && logFileURL != nil
        if busy {
            progress.doubleValue = max(progress.doubleValue, 1)
        }
    }

    private func failureHint(exitCode: Int32) -> String {
        let log = logView.string.lowercased()
        var hint = "失败阶段：\(lastStage)\n退出码：\(exitCode)"

        if log.contains("permission denied") || log.contains("operation not permitted") || log.contains("read-only file system") {
            hint += "\n可能原因：macOS 拦截了对 Docker.app 的写入。请确认已输入管理员密码；如果仍失败，请到“系统设置 > 隐私与安全性 > 应用管理”允许 Terminal 修改应用，或用命令行安装。"
        } else if log.contains("could not locate app.asar") || log.contains("could not find a desktop ui html") {
            hint += "\n可能原因：这个 Docker Desktop 版本的资源结构变化较大，需要适配新的 app.asar 路径或入口文件。"
        } else if log.contains("docker engine did not become available") {
            hint += "\n可能原因：Docker 引擎启动超时。安装器会自动恢复备份；也可以点“恢复原始 Docker”。"
        } else if log.contains("appears to have crashed") || log.contains("frontend did not stay running") {
            hint += "\n可能原因：补丁注入后前端启动失败。安装器会自动恢复备份；也可以点“恢复原始 Docker”。"
        } else if log.contains("no backups found") || log.contains("backup is incomplete") {
            hint += "\n可能原因：没有可用备份，或备份目录不完整。"
        } else {
            hint += "\n请查看窗口日志；日志会标出检测、备份、注入、启动或引擎检查中的具体失败位置。"
        }

        if let logFileURL {
            hint += "\n日志：\(logFileURL.path)"
        }
        return hint
    }

    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "好")
        alert.beginSheetModal(for: window)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
