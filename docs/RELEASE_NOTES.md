## Local Route Launcher 1.4.3 — Fresh update downloads

### 中文

- 修复点击“有更新”仍下载此前检测到的旧版本的问题。主窗口、macOS 菜单栏和 Windows 托盘现在会在点击时重新查询 GitHub 最新稳定版，再下载适用于当前平台和架构的安装包。
- 例如启动时检测到 v1.4.1、点击时已发布 v1.4.2，现在会下载 v1.4.2，而非继续使用缓存的 v1.4.1 链接。
- 查询失败、取消、最新版本缺少对应安装包时，不会回退旧下载链接；查询期间隐藏提醒并阻止重复请求和重复打开浏览器。
- 补充 macOS 更新模型与 Windows 已安装应用的回归测试。保持现有界面和直接下载方式，无新增弹窗，不自动安装。

**升级提示：**旧版程序不会自动获得此修复。如仍在运行旧版，请从本次 Release 手动下载对应安装包并安装；修复在 v1.4.3 及后续版本生效。

### English

- Fixed the update badge opening the installer cached by an earlier check. Clicking now refreshes GitHub's latest stable release and validates its platform/architecture installer before opening the download, across the main window, macOS menu and Windows tray.
- If startup detected v1.4.1 but v1.4.2 is available when clicked, the download now resolves to v1.4.2.
- Failed, cancelled or overlapping checks never fall back to a stale download. A latest release without the matching installer opens nothing. Hide the badge during checks and prevent duplicate browser launches.
- Added macOS update-model and installed Windows app regression coverage. Existing UI and direct-download behavior remain; no new dialog or automatic installation.

**Upgrading:** Existing installations do not acquire this fix automatically. Download the matching installer from this release and install it; the corrected behavior applies from v1.4.3 onward.

**Platforms:** macOS 13+ on Apple Silicon / Intel; Windows x64 installer minimum remains Windows 10 1809. Windows Server 2022 / 2025 automated checks do not replace client OS acceptance. Target apps retain independent OS requirements. See [Windows compatibility](https://github.com/oliver804/Local-Route-Launcher/blob/main/docs/WINDOWS-COMPATIBILITY.en.md).

**Distribution:** macOS packages are ad-hoc signed, not notarized; Windows installers are unsigned. Verify release origin and SHA-256 hashes and retain system protections.

Independent project, not affiliated with or endorsed by OpenAI or Google. Product names describe compatibility; trademarks belong to their owners.
