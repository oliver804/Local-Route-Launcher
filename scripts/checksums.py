#!/usr/bin/env python3
import hashlib
import os
import platform
import sys
from project_files import ROOT, version

release = ROOT / 'dist' / version()
arch = os.environ.get('MACOS_ARCH', platform.machine())
if arch not in ('arm64', 'x86_64'):
    raise SystemExit('MACOS_ARCH must be arm64 or x86_64')
names = [f'Local-Route-Launcher-{version()}-{arch}.dmg', f'Local-Route-Launcher-{version()}-source.zip']
text = ''.join(f'{hashlib.sha256((release / name).read_bytes()).hexdigest()}  {name}\n' for name in names)
# Platform builds must not overwrite each other's manifests. The release job
# generates SHA256SUMS.txt from all validated platform assets.
manifest = release / f'SHA256SUMS-{arch}.txt'
if '--verify' in sys.argv:
    if manifest.read_text() != text:
        raise SystemExit('Checksum mismatch')
    print('PASS: release checksums')
else:
    manifest.write_text(text)
    print('Wrote release checksums (filenames only; no local paths).')
