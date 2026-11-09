# Changelog / 更新日志

## 1.4.3 — 2026-11-09

- Refresh the latest stable GitHub release when the update badge is clicked, then open its validated platform/architecture installer instead of the URL cached at startup.
- Never fall back to an old installer after a failed, cancelled or overlapping refresh, or when the latest release lacks a matching installer; request cache revalidation and deduplicate concurrent main/menu/tray clicks.
- Add macOS model and installed Windows UI regression coverage for stale badges, unavailable installers, network failures, cancellation and repeated clicks. Keep the existing compact UI and direct-download behavior.
- 修复“有更新”下载此前检测到的旧版本：点击时重新查询最新稳定版，校验后下载；失败时不回退旧链接。

## 1.4.2 — 2026-11-09

- Lower the Windows installer minimum from Windows 10 22H2 (19045) to 1809 (17763), removing the installation block on 21H2 and corresponding LTSC editions; retain Windows 11 and x64 packaging.
- Run installed-app, isolated launch/connection, localized UI, tray and uninstall checks on Windows Server 2022 and 2025, recording the tested OS without host/user identifiers. Server checks do not establish Windows 10 client acceptance.
- Document the compatibility target, independent target-app requirements and remaining Windows 10 on-device validation; update bilingual downloads and website guidance.
- Windows 安装门槛降至 1809，包含 21H2 / 22H2 及对应 LTSC；不宣称支持所有 Windows 10 版本或架构。界面和代理机制保持不变。

## 1.4.1 — 2026-11-05

- Add a separate Intel Mac (x86_64) DMG alongside the Apple Silicon (arm64) DMG; both require macOS 13+.
- Select update installers by the running macOS binary architecture and hide updates when the matching asset is missing.
- Build and test both macOS architectures on native CI runners; validate each DMG's executable architecture and publish combined checksums with the Windows installer and source archive.
- Add explicit Apple Silicon / Intel download choices and compatibility guidance to the bilingual website and documentation. Intel target applications must themselves support Intel or Universal builds.
- 新增 Intel Mac（x86_64）独立安装包；按架构选择更新下载，并同步官网、双语说明及发布校验。

## 1.4.0 — 2026-10-30

- Apply the accepted compact layout: shared language/appearance/GitHub icons at the top right, original three-card content, two-line idle footer, and a compact menu/tray panel.
- Check stable launcher releases at startup. Show an update badge only for a newer matching installer; clicking directly downloads it without an update popup. Preserve existing startup-check preferences.
- Preserve symmetric artwork, native macOS menu icon appearance, zoom/fullscreen and close-to-menu behavior.
- Record the UI baseline and icon constraints; migrate project links to `oliver804/Local-Route-Launcher` while retaining existing app settings.
- 按已确认设计收紧主窗口及菜单栏/托盘布局，保留三张卡片与两行底部说明；新增启动器稳定版检查与静默提示，无自动下载安装。

- Added separate ChatGPT, Antigravity App and Antigravity IDE profiles and launch controls on macOS / Windows; existing ChatGPT preferences are retained.
- Added a multi-app sidebar and menu bar / tray controls, global nine-language selection and Follow system.
- Added target-specific probes and separate observations for recognized language-server descendants; connection snapshots do not establish full model or account access.
- Expanded migration, profile isolation, language, target validation and installed-app smoke coverage. Existing icon and Dock lifecycle behavior is retained.


## 1.3.0 — 2026-10-26

- Add seven interface languages to macOS and Windows: Traditional Chinese, Russian, Persian, Belarusian, Spanish, Arabic and Portuguese, alongside English and Simplified Chinese.
- Persist language preferences, respect explicit Chinese scripts, and support right-to-left layouts for Arabic and Persian. Declare all nine languages in the macOS bundle.
- Restore the native macOS menu bar symbol used in 1.0.0, with automatic light, dark and highlighted appearance handling.
- Protect Windows settings during operations and preserve unsaved input after success or failure.
- Expand localization, menu icon, window lifecycle and installer checks; update website and bilingual documentation. Installer wizards retain their existing language.

## 1.2.0 — 2026-10-19

- Windows x64 self-contained installer with bilingual WPF interface, themes, system tray, app discovery, process-scoped proxy launch, graceful stop and local diagnostics.
- Added Windows core, integration-fixture, UI and installer/uninstaller checks; release publication waits for both platform builds.
- Shared original icon artwork; updated website download choices, bilingual docs and announcement articles.
- Windows installer is unsigned. Actual ChatGPT account compatibility is not covered by the isolated CI fixture; restricted Store packages may reject direct launch.


## 1.1.0

- Rename the public application and release packages to Local Route Launcher; keep existing repository links and preference storage compatible.
  对外名称与发布包更名为 Local Route Launcher，保留现有仓库链接和偏好设置兼容性。
- Add immediate, persistent English / Simplified Chinese switching for launcher UI, menu panel, validation, and reports.
  主窗口、菜单栏、校验提示和诊断报告支持中英文即时切换并保存选择。
- Refresh bilingual previews and documentation; clarify independent branding, authorized use, compatibility, and diagnostic limits.
  更新双语预览及文档，明确独立品牌、授权使用、兼容性及诊断边界。

## 1.0.0

Initial public release / 首个开源版本。

- Per-launch HTTP proxy settings for compatible Electron versions of ChatGPT.
  为兼容的 Electron 版 ChatGPT 单独设置启动代理。
- Start, gracefully stop, and inspect proxy configuration and TCP connections.
  启动、正常停止应用，并检查代理参数和 TCP 连接。
- Menu bar access; hide the Dock icon when the main window is closed.
  支持菜单栏操作；关闭主窗口时隐藏 Dock 图标。
- Light and dark appearance with a shared application icon.
  适配浅色与深色外观，统一应用图标。
- Chinese and English documentation, source checks, and DMG packaging.
  中英文文档、源码检查与 DMG 打包流程。
