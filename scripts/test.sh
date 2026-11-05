#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
require_macos
python3 scripts/privacy-check.py
swiftc "${SWIFT_FLAGS[@]}" -parse-as-library Sources/Localization.swift Sources/AdditionalTranslations.swift Sources/ProxyCore.swift Tests/CoreTests.swift -o "$BUILD_DIR/core-tests"
"$BUILD_DIR/core-tests"
swiftc "${SWIFT_FLAGS[@]}" -parse-as-library Sources/Localization.swift Sources/AdditionalTranslations.swift Sources/ProxyCore.swift \
  Sources/ReleaseUpdate.swift Sources/LauncherModel.swift Tests/LanguageTests.swift -framework SwiftUI -framework AppKit -o "$BUILD_DIR/language-tests"
"$BUILD_DIR/language-tests"
# Compile native rendering tests on CI as well; execution needs a GUI session
# and is covered by make ui on an interactive Mac.
swiftc "${SWIFT_FLAGS[@]}" -parse-as-library Sources/BrandMark.swift Tests/MenuBarIconTests.swift \
  -framework SwiftUI -framework AppKit -o "$BUILD_DIR/menu-icon-tests"
swiftc "${SWIFT_FLAGS[@]}" -parse-as-library Sources/Localization.swift Sources/AdditionalTranslations.swift Sources/ProxyCore.swift \
  Sources/ReleaseUpdate.swift Sources/LauncherModel.swift Tests/UpdateTests.swift -framework SwiftUI -framework AppKit -o "$BUILD_DIR/update-tests"
"$BUILD_DIR/update-tests"
