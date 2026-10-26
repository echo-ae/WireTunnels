#!/bin/bash
# Build only. Never launches the app, installs a helper, or touches VPN profiles.
set -euo pipefail
cd "$(dirname "$0")/.."
identity=7D9261FAC709D8C232A414B42BA38C6E0DFC17A8
xcodebuild -project WireTunnels.xcodeproj -scheme WireTunnels \
  -configuration Release -derivedDataPath build/hardened-release \
  SWIFT_OPTIMIZATION_LEVEL=-O ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO ENABLE_DEBUG_DYLIB=NO \
  CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM=C72ZK246A3 \
  CODE_SIGN_IDENTITY="$identity" OTHER_CODE_SIGN_FLAGS=--timestamp clean build
python3 Scripts/verify_hardened_release.py build/hardened-release/Build/Products/Release/WireTunnels.app
