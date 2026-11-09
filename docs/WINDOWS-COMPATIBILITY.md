# Windows 兼容性

**中文** | [English](WINDOWS-COMPATIBILITY.en.md)

## 安装范围

从 1.4.2 开始，x64 安装包最低要求为 **Windows 10 1809（build 17763）**。Windows 10 21H2（19044）、22H2（19045）及对应的 LTSC 2019 / 2021 位于此范围内，Windows 11 继续保留。此前安装门槛为 22H2，因此 21H2 会在运行应用前被安装程序拒绝。

这是安装和适配目标，不是对所有系统环境的实测承诺。暂不覆盖 Windows 10 1809 之前的版本、32 位 Windows、ARM64、精简或组件缺失的系统。安装器的 x64 兼容检测可能允许模拟执行，但这不代表 ARM64 已得到支持。

## 依据和边界

- 应用使用自包含的 .NET 10 WPF / Windows Forms，用户无需另装 .NET。未使用要求 22H2 的 Windows App SDK 或 WinUI 组件。
- 当前原生接口包括窗口查找、消息、命令行拆分和 TCP 表读取；进程查询使用 Windows PowerShell / CIM，应用发现使用固定的 Appx 查询，并保留手动选择 EXE。现有路径未发现要求 22H2 的系统接口。
- `MinVersion` 位于 `Windows/Installer/launcher.iss`；它应反映产品最低版本，而非构建机器的版本。[Inno Setup 文档](https://jrsoftware.org/ishelp/topic_setup_minversion.htm)。
- [.NET 10 官方支持清单](https://github.com/dotnet/core/blob/main/release-notes/10.0/supported-os.md)包含特定 Windows 10 Enterprise / IoT / LTSC 版本。允许安装不等于微软仍支持所有 Home / Pro 版本；请使用仍有安全维护的系统。
- ChatGPT、Antigravity App 和 IDE 有各自的系统和架构要求。启动器能够安装，不代表这些应用一定可运行；不修改目标应用或绕过其系统要求。

## 验证记录

| 环境 | 验证方式 | 范围 |
| --- | --- | --- |
| Windows Server 2022 / 2025 x64 | GitHub Actions，结果见对应工作流 | 构建、自包含安装包启动、隔离应用启动及连接、九语言深浅主题、托盘生命周期、卸载 |
| Windows 10 1809 / LTSC 2019 x64 | 待实机或虚拟机验收 | 已放开安装门槛，未宣称完整实测 |
| Windows 10 21H2 / LTSC 2021 x64 | 待实机或虚拟机验收 | 已移除旧的 22H2 安装限制 |
| Windows 10 22H2 / Windows 11 x64 | 待目标机器验收 | 原有适配范围，服务器 CI 不替代客户端实测 |

CI 的 `windows-validation-*` 附件包含 `environment.json`，记录实际系统名称、版本、架构和安装最低版本，不记录机器名、用户名或序列号。发布采用 Windows Server 2022 构建的安装包；两个服务器环境分别构建并运行测试，不能视为同一安装包在两台机器上的测试。

在目标系统验收时，依次检查：普通用户安装；首次启动；语言和外观切换；关闭窗口后托盘重新打开；保存设置并重启后恢复；启动已授权的兼容目标应用并检查连接；新版下载入口；退出并卸载。升级前保存配置，升级后确认仍可读取。真实账号、模型权限和所有后台流量不在隔离测试证明范围内。

如需复现自动测试，在目标 Windows x64 系统安装 .NET SDK 10.0.402 和 Inno Setup 6 后，运行 `./scripts/build-windows.ps1 -Test`。SDK 仅供构建测试使用，普通用户安装发布包不需要它。测试在仓库构建目录安装隔离副本，不应与已运行的启动器同时执行。
