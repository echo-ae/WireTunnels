# Hardened preview — 2026-10-26

Fork: echo-ae/WireTunnels, branch codex/helper-security-hardening.

## Changes

- Redact private and preshared keys from both helper status APIs. Drop unexpected dump record shapes and filter personal status by recorded UID; managed status remains shared.
- Copy the source application to a root-owned 0700 staging directory and verify its signature, team, identifier, sealed resources and nested code there before installing tools. Reject symlinked resource directories/files. Hashes now measure a verified snapshot rather than a mutable user-owned source.
- Record personal runtime ownership in root-owned metadata. Serialize configuration mutations across XPC sessions; reject cross-user overwrites, collisions with managed profiles, and unowned legacy runtime files. Enforce managed connect/disconnect policy in the helper, including staging. Require ownership/policy for inventory interface resolution.
- Switch signing team to C72ZK246A3. Disable upstream Sparkle initialization/feed so a private build cannot silently revert to upstream.

## Signing

Chosen Developer ID Application: certificate 5H3J5XKJVN, expires 2027-11-25.
SHA-1 signing identity: 7D9261FAC709D8C232A414B42BA38C6E0DFC17A8.
Private key is in the local login Keychain; temporary PEM was deleted. No keys in Git.
An extra certificate Z43UP44B87 (expires 2027-02-01) must not be used. A user-authorized revocation request was sent to Apple Product Security; revocation is not yet confirmed.

Build a separate signed preview using `bash Scripts/build_hardened_preview.sh`.
The script pins the exact identity, not just the non-unique certificate name.

## Validation and limits

- Full `python3 Tests/run_tests.py` suite passes, including synthetic ownership, secret-redaction and forged-bundle tests.
- Signature regression against the signed app passes: valid snapshot accepted, wrong team and modified wg-quick rejected. The test modifies only a temporary copy and never executes the app/helper.
- Signed preview and embedded helper pass codesign strict verification, with hardened runtime and timestamp.
- Xcode 26.6's optimized Swift compilation crashes in EarlyPerfInliner for the upstream generic RecoverableJSONStore destructor, with both -O and -Osize. Preview uses -Onone; it is not the optimized production release. This workaround does not disable signature validation or hardened runtime.
- Notarization has not been performed. No claim of Gatekeeper distribution readiness.
- No root-helper end-to-end installation, multi-user integration or live tunnel tests were performed. Existing application/helper/profiles were not replaced or started by this work.
- Bundle IDs/runtime paths deliberately remain upstream-compatible. DO NOT LAUNCH beside the installed version: a planned replacement and explicit migration are required. Personal legacy runtime files have no ownership records; migrate them explicitly after disconnecting via the original helper, not by silently assigning an arbitrary UID.
- These changes address the audited entry points, not a comprehensive review of all global DNS/PF/route management APIs. A full multi-user isolation claim would require auditing those paths too.

Before installation: resolve optimized compiler build, complete notarization if desired for distribution, review ownership migration and test on an isolated macOS environment. The user must approve replacing the installed application separately.
