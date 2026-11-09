## Local Route Launcher 1.4.2 — Windows 10 compatibility

### 中文

- Windows x64 安装最低版本从 Windows 10 22H2（19045）降至 1809（17763），修复 21H2 被安装程序拒绝的问题，覆盖对应的 LTSC 2019 / 2021，继续保留 Windows 11。
- Windows Server 2022 / 2025 分别构建和运行安装、启动、隔离应用连接、九语言深浅主题、托盘和卸载测试；记录实际测试系统版本，避免与 Windows 10 客户端实测混淆。
- 同步中英文官网、下载说明和兼容性文档。界面、应用图标、代理机制与现有设置保持不变。

**范围：**仅提供 Windows x64 安装包；不承诺支持所有 Windows 10 版本、32 位或 ARM64。1809 / 21H2 / 22H2 及 LTSC 仍需目标机器验收。ChatGPT 与 Antigravity 有独立的系统要求，启动器不会绕过这些要求。详情见[兼容性说明](https://github.com/oliver804/Local-Route-Launcher/blob/main/docs/WINDOWS-COMPATIBILITY.md)。

**升级：**从托盘退出启动器后运行新版 EXE，安装到原位置即可保留用户设置。无需卸载旧版或另装 .NET。Mac 仍分别提供 Apple Silicon 与 Intel DMG，要求 macOS 13+。

### English

- Lowered the Windows x64 installer minimum from Windows 10 22H2 (19045) to 1809 (17763), removing the installation block on 21H2 and corresponding LTSC 2019 / 2021 editions. Windows 11 remains eligible.
- Build and run installation, startup, isolated app connections, nine-language light/dark UI, tray and uninstall tests separately on Windows Server 2022 / 2025. Record the actual OS so server results are not mistaken for Windows 10 client validation.
- Updated bilingual downloads, website and compatibility guidance. UI, artwork, proxy mechanisms and existing settings are unchanged.

**Scope:** Windows x64 only; this does not claim support for every Windows 10 version, 32-bit Windows or ARM64. Windows 10 1809 / 21H2 / 22H2 and LTSC editions still need target-machine acceptance. Target apps have independent OS requirements. See [compatibility details](https://github.com/oliver804/Local-Route-Launcher/blob/main/docs/WINDOWS-COMPATIBILITY.en.md).

**Upgrade:** Quit the launcher from its tray, then install the new EXE to the existing location. Settings are retained; no prior uninstall or separate .NET installation is required. Separate Apple Silicon and Intel DMGs remain available for macOS 13+.

**Distribution:** macOS packages are ad-hoc signed, not notarized; Windows installers are unsigned. Verify release origin and SHA-256 hashes and retain system protections.

Independent project, not affiliated with or endorsed by OpenAI or Google. Product names describe compatibility; trademarks belong to their owners. Use authorized networks and services in accordance with applicable law and service terms.
