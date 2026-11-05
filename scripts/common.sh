#!/bin/bash
# Shared metadata. VERSION is the only source of the release version.
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"
PROJECT_VERSION="$(tr -d '\r\n' < VERSION)"
if [[ ! "$PROJECT_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "VERSION must contain a semantic version such as 1.0.0" >&2
  exit 1
fi
HOST_ARCH="$(uname -m)"
MACOS_ARCH="${MACOS_ARCH:-$HOST_ARCH}"
case "$MACOS_ARCH" in
  arm64|x86_64) ;;
  *) echo "MACOS_ARCH must be arm64 or x86_64." >&2; exit 1 ;;
esac
export MACOS_ARCH
BUILD_DIR="$PROJECT_ROOT/build/macos-$MACOS_ARCH"
APP_PATH="$PROJECT_ROOT/build/release/$MACOS_ARCH/Local Route Launcher.app"
RELEASE_DIR="$PROJECT_ROOT/dist/$PROJECT_VERSION"
DMG_NAME="Local-Route-Launcher-$PROJECT_VERSION-$MACOS_ARCH.dmg"
SOURCE_NAME="Local-Route-Launcher-$PROJECT_VERSION-source.zip"
APP_SOURCES=(Sources/Localization.swift Sources/AdditionalTranslations.swift Sources/BrandMark.swift Sources/ProxyCore.swift Sources/ReleaseUpdate.swift Sources/LauncherModel.swift Sources/LauncherApp.swift)
COMMON_SWIFT_FLAGS=(-swift-version 5 -file-compilation-dir .
  -debug-prefix-map "$PROJECT_ROOT=." -file-prefix-map "$PROJECT_ROOT=.")
SWIFT_FLAGS=("${COMMON_SWIFT_FLAGS[@]}" -target "$MACOS_ARCH-apple-macosx13.0"
  -module-cache-path "$BUILD_DIR/module-cache")
# Asset helpers run on the build host, even when cross-compiling the app.
HOST_SWIFT_FLAGS=("${COMMON_SWIFT_FLAGS[@]}" -target "$HOST_ARCH-apple-macosx13.0"
  -module-cache-path "build/macos-$HOST_ARCH/module-cache")

require_macos() {
  if [[ "$(uname -s)" != Darwin || ! "$HOST_ARCH" =~ ^(arm64|x86_64)$ ]]; then
    echo "Building and GUI tests require an Apple Silicon or Intel Mac." >&2
    exit 1
  fi
  command -v swiftc >/dev/null
  command -v python3 >/dev/null
  mkdir -p "$BUILD_DIR/module-cache" "build/macos-$HOST_ARCH/module-cache"
}
