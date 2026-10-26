#!/bin/bash
# Submit only to Apple's notary service. Does not install, launch or publish a release.
set -euo pipefail
repo_root="$(cd "$(dirname "$0")/.." && pwd)"
app_path="${1:?Usage: bash Scripts/notarize_hardened_release.sh /path/WireTunnels.app [keychain-profile]}"
profile="${2:-wiretunnels-notary}"
artifacts="${repo_root}/build/notarized-release"
mkdir -p "$artifacts"
python3 "$repo_root/Scripts/verify_hardened_release.py" "$app_path"
archive="$artifacts/WireTunnels-hardened-universal.zip"
ditto -c -k --keepParent "$app_path" "$archive"
xcrun notarytool submit "$archive" --keychain-profile "$profile" --wait --output-format json > "$artifacts/submission.json"
submission_id=$(python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d["status"] == "Accepted", d; print(d["id"])' "$artifacts/submission.json")
xcrun notarytool log "$submission_id" --keychain-profile "$profile" "$artifacts/notary-log.json"
xcrun stapler staple "$app_path"
xcrun stapler validate "$app_path"
spctl --assess --type execute --verbose=2 "$app_path"
python3 "$repo_root/Scripts/verify_hardened_release.py" "$app_path"
ditto -c -k --keepParent "$app_path" "$archive"
shasum -a 256 "$archive" > "$archive.sha256"
printf 'Notarized artifact: %s\n' "$archive"
