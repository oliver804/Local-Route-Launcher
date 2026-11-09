# Usage boundaries

[中文](USAGE.md) | **English**

Local Route Launcher is an independent, MIT-licensed utility that passes local HTTP proxy settings to compatible applications. It is not a proxy provider, VPN, ChatGPT client, or OpenAI service. It does not include ChatGPT binaries or grant access to accounts, subscriptions, or restricted services.

Use it only with networks, proxy services, and accounts you are authorized to use. Applicable laws, network policies, and third-party service terms still apply. The project does not authorize bypassing access restrictions, account controls, rate limits, or other protective measures. Availability and permission to access a service are separate from whether a connection succeeds.

The launcher supports Apple Silicon and Intel Macs running macOS 13+, or Windows 10 1809+ / Windows 11 x64. Target apps must be detectable, directly launchable compatible Electron builds of ChatGPT, Antigravity App or Antigravity IDE. Intel Macs require compatible Intel or Universal target-app builds; the launcher cannot run Apple-Silicon-only apps on Intel Macs. Updates to the target application can change its behavior. The launcher cannot guarantee that all traffic follows the supplied settings: voice, WebRTC, UDP, and some child processes may behave differently. Diagnostics are snapshots, not a privacy, anonymity, security, or account-access guarantee.

The Windows installer minimum is 1809 (build 17763), including 21H2 / 22H2 and corresponding LTSC editions. Automated tests run on Windows Server and do not replace on-device acceptance for each Windows 10 version. Target apps must also support the installed OS. See [compatibility details](WINDOWS-COMPATIBILITY.en.md).

Product names such as ChatGPT and Antigravity identify compatibility only; trademarks belong to their respective owners. This project is not affiliated with, sponsored by, or endorsed by OpenAI or Google. The internal preferences identifier is retained for upgrade compatibility; the application’s public name is Local Route Launcher.

macOS release binaries are ad-hoc signed and are not Apple Developer ID signed or notarized. Review the source, release checksums, compatibility notes, and macOS prompts before installation. The [MIT license](../LICENSE) covers the project code and its warranty limitations; it does not grant rights to third-party trademarks or services. [Privacy](PRIVACY.en.md) · [Third-party notices](../THIRD_PARTY_NOTICES.md).

Windows: requires a directly launchable compatible Electron target app; restricted Microsoft Store packages may reject direct launch. Windows ARM64 is not supported. Windows installers are unsigned and may trigger SmartScreen. Do not disable security protections or bypass managed-device policies.

## Interface and updates

Select an app in the sidebar and save its host, port and path independently. Language, appearance and GitHub controls live at the upper right and are also available in the menu/tray panel. Closing the main window keeps the launcher accessible there.

The version-adjacent badge appears only when a newer stable launcher release has an installer for this platform and build architecture. Clicking downloads that installer directly in your browser, without an intermediate panel. Run the downloaded installer to finish updating. No badge is shown otherwise; offline checks do not interrupt use.
