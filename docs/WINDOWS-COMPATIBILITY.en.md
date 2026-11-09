# Windows compatibility

[中文](WINDOWS-COMPATIBILITY.md) | **English**

## Installation range

Starting with 1.4.2, the x64 installer requires **Windows 10 1809 (build 17763)** or later. This includes 21H2 (19044), 22H2 (19045), and the corresponding LTSC 2019 / 2021 editions; Windows 11 remains eligible. The previous 22H2 minimum rejected installation on 21H2 before the app could run.

This is an installation and compatibility target, not a claim that every environment has been tested. Windows 10 before 1809, 32-bit Windows, ARM64, and stripped-down systems with missing components are outside this scope. The installer's x64-compatible architecture detection may permit emulation; that does not establish ARM64 support.

## Basis and limits

- The app bundles .NET 10 WPF / Windows Forms; users do not need a separate .NET installation. It does not depend on Windows App SDK or WinUI components requiring 22H2.
- Current native calls cover window lookup, messaging, command-line parsing and TCP tables. Process discovery uses Windows PowerShell / CIM; app discovery uses fixed Appx queries with manual EXE selection as a fallback. No 22H2-only system API was found in these paths.
- `MinVersion` in `Windows/Installer/launcher.iss` represents the product minimum, not the build machine's OS. See [Inno Setup documentation](https://jrsoftware.org/ishelp/topic_setup_minversion.htm).
- The [.NET 10 support list](https://github.com/dotnet/core/blob/main/release-notes/10.0/supported-os.md) includes specific Windows 10 Enterprise / IoT / LTSC editions. Allowing installation does not mean Microsoft still supports every Home / Pro release. Use an OS receiving security maintenance.
- ChatGPT, Antigravity App and IDE have independent OS and architecture requirements. Installing the launcher does not make an incompatible target app work; the launcher does not modify target apps or bypass their requirements.

## Validation record

| Environment | Validation method | Scope |
| --- | --- | --- |
| Windows Server 2022 / 2025 x64 | GitHub Actions; consult the corresponding workflow results | Build, self-contained installation/startup, isolated app launch/connections, nine languages in both themes, tray lifecycle, uninstall |
| Windows 10 1809 / LTSC 2019 x64 | On-device or VM acceptance pending | Installer eligibility expanded; no full acceptance claim |
| Windows 10 21H2 / LTSC 2021 x64 | On-device or VM acceptance pending | Previous 22H2 installation restriction removed |
| Windows 10 22H2 / Windows 11 x64 | Target-machine acceptance pending | Existing target range; server CI is not client OS validation |

CI's `windows-validation-*` artifacts include `environment.json` with the actual OS name, version, architecture and installer minimum, excluding computer names, usernames and serial numbers. Releases use the installer built on Windows Server 2022. Each server builds and tests its own package; this is not a test of the same binary on both machines.

On a target system, check per-user installation, first launch, language and theme switching, close-to-tray and reopening, settings persistence after restart, authorized compatible target-app launch and connection checks, the update download entry, exit and uninstall. Preserve settings before an upgrade and verify they remain readable afterward. Isolated tests do not establish real account/model access or routing of every background connection.

To reproduce automated checks on Windows x64, install .NET SDK 10.0.402 and Inno Setup 6, then run `./scripts/build-windows.ps1 -Test`. The SDK is needed only for building tests, not for using a release installer. Tests install an isolated copy under the repository build directory and should not run alongside an existing launcher process.
