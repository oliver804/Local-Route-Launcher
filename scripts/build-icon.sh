#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
require_macos
ICON_DESTINATION="${1:-$PROJECT_ROOT/build/brand-icon/AppIcon.icns}"
mkdir -p "$(dirname "$ICON_DESTINATION")"
swiftc "${HOST_SWIFT_FLAGS[@]}" -parse-as-library Sources/BrandMark.swift scripts/make-icon.swift \
  -framework SwiftUI -framework AppKit -o "$BUILD_DIR/make-icon"
"$BUILD_DIR/make-icon" "$ICON_DESTINATION"
