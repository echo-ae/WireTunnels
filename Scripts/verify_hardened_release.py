#!/usr/bin/env python3
"""Verify release signatures/architectures without executing the app or helper."""
import hashlib
import json
import tempfile
import pathlib
import plistlib
import subprocess
import sys

app = pathlib.Path(sys.argv[1]).resolve()
subprocess.run(['codesign', '--verify', '--deep', '--strict', str(app)], check=True)
requirement = 'anchor apple generic and identifier "com.fmdigitech.WireTunnels" and certificate leaf[subject.OU] = "C72ZK246A3"'
subprocess.run(['codesign', '--verify', '-R', '=' + requirement, str(app)], check=True)
paths = [app, app / 'Contents/Library/LaunchDaemons/com.fmdigitech.WireTunnels.helper', app / 'Contents/Resources/wireguard/wg', app / 'Contents/Resources/wireguard/wireguard-go']
for path in paths:
    with tempfile.TemporaryDirectory(prefix='wiretunnels-cert-check-') as temporary:
        prefix = str(pathlib.Path(temporary) / 'cert')
        subprocess.run(['codesign', '-d', '--extract-certificates=' + prefix, str(path)], capture_output=True, check=True)
        leaf = pathlib.Path(prefix + '0').read_bytes()
        assert hashlib.sha1(leaf).hexdigest().upper() == '7D9261FAC709D8C232A414B42BA38C6E0DFC17A8', 'Unexpected signing certificate'
    details = subprocess.run(['codesign', '-d', '--verbose=4', str(path)], capture_output=True, text=True, check=True).stderr
    assert 'TeamIdentifier=C72ZK246A3' in details, details
    assert '(runtime)' in details and 'Timestamp=' in details, details
    raw = subprocess.run(['codesign', '-d', '--entitlements', ':-', str(path)], capture_output=True, check=True).stdout
    entitlements = plistlib.loads(raw) if raw else {}
    for key in ['get-task-allow', 'cs.disable-library-validation', 'cs.allow-unsigned-executable-memory', 'cs.allow-dyld-environment-variables']:
        assert not entitlements.get('com.apple.security.' + key, False), (path, key)
    print('PASS: hardened runtime, timestamp, team and safe entitlements:', path.name)
for path in [app / 'Contents/MacOS/WireTunnels', paths[1], app / 'Contents/Resources/wireguard/wg', app / 'Contents/Resources/wireguard/wireguard-go']:
    archs = subprocess.check_output(['lipo', '-archs', str(path)], text=True).split()
    assert set(archs) == {'arm64', 'x86_64'}, (path, archs)
print('PASS: universal app, helper and WireGuard executables')

manifest = json.loads((app / 'Contents/Resources/wireguard/manifest.json').read_text())
assert {a['name'] for a in manifest['artifacts']} == {'wg', 'wg-quick', 'wireguard-go'}
for artifact in manifest['artifacts']:
    data = (app / 'Contents/Resources/wireguard' / artifact['name']).read_bytes()
    assert hashlib.sha256(data).hexdigest() == artifact['sha256']
    assert len(data) == artifact['size']
assert not (app / 'Contents/Frameworks/Sparkle.framework').exists()
print('PASS: signed tool hashes match manifest; unused updater absent')
