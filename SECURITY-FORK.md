# Hardened release — 2026-10-26

Fork: echo-ae/WireTunnels, branch codex/helper-security-hardening.

## Changes

- Redact private and preshared keys from both helper status APIs. Drop unexpected dump record shapes and filter personal status by recorded UID; managed status remains shared.
- Copy the source application to a root-owned 0700 staging directory and verify its signature, team, identifier, sealed resources and nested code there before installing tools. Reject symlinked resource directories/files. Hashes now measure a verified snapshot rather than a mutable user-owned source.
- Record personal runtime ownership in root-owned metadata. Serialize configuration mutations across XPC sessions; reject cross-user overwrites, collisions with managed profiles, and unowned legacy runtime files. Enforce managed connect/disconnect policy in the helper, including staging. Require ownership/policy for inventory interface resolution.
- Switch signing team to C72ZK246A3. Remove the unused Sparkle dependency and its upstream feed so a private build cannot silently revert to upstream.

## Signing

Chosen Developer ID Application: certificate 5H3J5XKJVN, expires 2027-11-25.
SHA-1 signing identity: 7D9261FAC709D8C232A414B42BA38C6E0DFC17A8.
Private key is in the local login Keychain; temporary PEM was deleted. No keys in Git.
An extra certificate Z43UP44B87 (expires 2027-02-01) must not be used. A user-authorized revocation request was sent to Apple Product Security; revocation is not yet confirmed.

Build a universal (arm64 + x86_64), optimized signed release using `bash Scripts/build_hardened_release.sh`. The older preview script is retained for diagnostics only.
The script pins the exact identity, not just the non-unique certificate name.

## Validation and limits

- Full `python3 Tests/run_tests.py` suite passes, including synthetic ownership, secret-redaction and forged-bundle tests.
- Signature regression against the signed app passes: valid snapshot accepted, wrong team and modified wg-quick rejected. The test modifies only a temporary copy and never executes the app/helper.
- Signed release and embedded helper pass codesign strict verification, with hardened runtime and timestamp.
- Xcode 26.6 matches Swift issue https://github.com/swiftlang/swift/issues/90385: EarlyPerfInliner crashes on the synthesized generic destructor with default MainActor isolation. A documented `@_optimize(none) deinit {}` limits the compiler workaround to that destructor. The universal Release uses -O and whole-module optimization everywhere else, preserves actor isolation, and excludes debug dylibs. Optimized metadata tests exercise recovery, corrupt-file preservation, safe-write failure paths and 0600 permissions.
- Sign bundled WireGuard tools after copying from the build cache, using the selected Developer ID and a timestamp; verify their final manifest hashes. This prevents a prior ad-hoc cache from contaminating a release.
- Disabled Xcode base-entitlement injection so Release carries no get-task-allow.
- Removed the upstream helper entitlement disabling library validation: helper links only platform frameworks and requires no such exception.
- Apple notarization accepted submission `7650ef6b-c4b2-40e1-a39b-4df4d3699abd`. Stapling and ticket validation passed; Gatekeeper reports `accepted`, source `Notarized Developer ID`. Final signature, entitlement, architecture and tool-manifest checks passed after stapling.
- Final local archive: `WireTunnels-1.0.7-hardened-universal.zip`; SHA-256 `95860b8da172e853fb9d3dd97f3339d980487d5563ec7e12acecf5b0a14bcfea`. No GitHub Release or binary publication performed.
- Reproduce notarization using `bash Scripts/notarize_hardened_release.sh /absolute/path/WireTunnels.app wiretunnels-notary`; credentials stay in Keychain. The script staples, validates and repackages without installing or launching.
- No root-helper end-to-end installation, multi-user integration or live tunnel tests were performed. Existing application/helper/profiles were not replaced or started by this work.
- Bundle IDs/runtime paths deliberately remain upstream-compatible. DO NOT LAUNCH beside the installed version: a planned replacement and explicit migration are required. Personal legacy runtime files have no ownership records; migrate them explicitly after disconnecting via the original helper, not by silently assigning an arbitrary UID.
- These changes address the audited entry points, not a comprehensive review of all global DNS/PF/route management APIs. A full multi-user isolation claim would require auditing those paths too.

Before installation: review ownership migration and test on an isolated macOS environment. The user must approve replacing the installed application separately.
