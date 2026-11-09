# 使用边界

**中文** | [English](USAGE.en.md)

Local Route Launcher 是独立开发、采用 MIT 许可证的工具，用于向兼容应用传入本地 HTTP 代理启动设置。它不是代理服务提供商、VPN、ChatGPT 客户端或 OpenAI 服务，不包含 ChatGPT 程序，也不提供账号、订阅或受限服务的访问权限。

请仅用于有权使用的网络、代理服务和账号，并遵守适用法律、网络管理规定及第三方服务条款。项目不授予绕过访问限制、账号控制、速率限制或其他保护措施的权限。连接成功不等于拥有访问权限，也不代表服务一定可用。

启动器支持 Apple Silicon / Intel Mac（macOS 13+），以及 Windows 10 1809+ / Windows 11 x64。目标应用需为可识别且可直接启动的兼容 Electron 版 ChatGPT、Antigravity App 或 Antigravity IDE。Intel Mac 还要求目标应用提供兼容的 Intel 或 Universal 版本；仅支持 Apple Silicon 的目标应用不能因此运行在 Intel Mac 上。目标应用更新可能改变行为。不保证全部流量遵循配置，语音、WebRTC、UDP 及部分子进程可能采用其他连接方式。诊断结果只是即时快照，不构成隐私、匿名、安全或账号可用性保证。

Windows 安装最低版本为 1809（build 17763），包含 21H2 / 22H2 及对应 LTSC；自动测试运行在 Windows Server，不能替代各 Windows 10 版本的实机验收。目标应用也必须支持当前系统。[详细兼容性说明](WINDOWS-COMPATIBILITY.md)。

ChatGPT、Antigravity 等产品名称仅用于说明兼容性，商标归各自权利人所有。本项目与 OpenAI / Google 无隶属、赞助或背书关系。内部偏好设置标识为保持升级兼容而保留；应用对外名称为 Local Route Launcher。

macOS 发布包使用 ad-hoc 签名，尚未取得 Apple Developer ID 签名或公证。安装前请核对源码、校验文件、兼容性说明和 macOS 提示。[MIT 许可证](../LICENSE)适用于项目代码及其免责条款，不授予第三方商标或服务的使用权。[隐私说明](PRIVACY.md) · [第三方说明](../THIRD_PARTY_NOTICES.md)。

Windows：需要能够直接启动的 兼容 Electron 应用；受限制的商店安装包可能不兼容。暂不支持 ARM64。安装包未签名，可能出现 SmartScreen 提示，不应关闭系统安全功能或绕过设备管理策略。

## 界面与更新

在左侧选择应用；右侧分别保存该应用的地址、端口与路径。右上角的语言、外观和 GitHub 图标提供全局入口，菜单栏/托盘中也可访问。关闭主窗口仍可从菜单栏/托盘打开。

仅在发现可下载的稳定新版时，版本旁显示“有更新”。点击直接下载当前平台和构建架构对应的安装包，再运行安装包完成更新；无中间弹窗，没有新版时不显示按钮。更新检查仅针对启动器，网络不可用不影响使用。
