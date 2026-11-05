## Local Route Launcher 1.4.1 — Intel Mac support

### 中文

- 新增 macOS Intel（x86_64）DMG，与 Apple Silicon（arm64）及 Windows x64 安装包一同提供。
- 更新检查按启动器构建架构选择安装包，避免 Intel 版误下载 arm64 DMG。
- 两种 Mac 架构分别在原生 GitHub Actions runner 构建、测试并校验安装包；统一提供 SHA-256 校验文件。
- 官网、中英文下载说明和博客增加 Intel 下载入口及芯片选择指引。现有多应用配置、语言、外观和菜单栏操作保持不变。

**如何选择：** 打开苹果菜单 →「关于本机」。Apple M 系列芯片选择 `arm64.dmg`；Intel 处理器选择 `x86_64.dmg`。两个版本均要求 macOS 13+。Intel Mac 上的目标应用也必须提供兼容的 Intel 或 Universal 版本；启动器不能让仅支持 Apple Silicon 的应用运行在 Intel Mac 上。

### English

- Added a macOS Intel (`x86_64`) DMG alongside Apple Silicon (`arm64`) and Windows x64 installers.
- Update checks select installers by launcher build architecture, preventing Intel builds from downloading arm64 packages.
- Each Mac architecture is built, tested and package-verified on a native GitHub Actions runner, with combined SHA-256 checksums.
- Updated the bilingual website, documentation and blog with Intel downloads and chip-selection guidance. Existing profiles, languages, appearance and menu-bar controls are unchanged.

**Choose your download:** Open Apple menu → About This Mac. Choose `arm64.dmg` for Apple M-series chips or `x86_64.dmg` for Intel processors. Both require macOS 13+. Target apps on Intel Macs must also provide compatible Intel or Universal builds; the launcher cannot run Apple-Silicon-only apps on Intel hardware.

**Validation limits:** Automated architecture, package and isolated process/connection checks do not establish target-app account compatibility, model access or complete traffic routing. Actual target-app use on an Intel Mac still requires validation in that environment. Windows requires Windows 10 22H2 / Windows 11 x64 and a directly launchable compatible target build.

**Distribution:** macOS packages are ad-hoc signed, not notarized; Windows installers are unsigned. Verify release origin and SHA-256 hashes and retain system protections.

**Privacy:** Optional startup update checks send ordinary request metadata to GitHub, without proxy profiles, app paths, reports, accounts or chats. See [privacy details](https://github.com/oliver804/Local-Route-Launcher/blob/main/docs/PRIVACY.en.md).

Independent project, not affiliated with or endorsed by OpenAI or Google. ChatGPT and Antigravity identify compatibility only; trademarks belong to their owners. Use authorized networks and services in accordance with applicable laws and terms. No proxy service is included.
