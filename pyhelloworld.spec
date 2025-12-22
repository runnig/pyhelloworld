# -*- mode: python ; coding: utf-8 -*-

import sys
from pathlib import Path

# Get the project root directory
project_root = Path(SPECPATH)
src_path = project_root / 'src'
data_path = project_root / 'data'

block_cipher = None

a = Analysis(
    [str(src_path / 'pyhelloworld' / 'pyhelloworld.py')],
    pathex=[str(src_path)],
    binaries=[],
    datas=[
        # Include data files from the data directory
        (str(data_path / 'data.txt'), '.'),
    ],
    hiddenimports=[
        # Ensure all modules are properly included
        'pyhelloworld.paths',
        'pyhelloworld.pyhelloworld',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[
        # Exclude unnecessary modules to reduce bundle size
        'tkinter',
        'matplotlib',
        'numpy',
        'pandas',
        'scipy',
        'PIL',
        'IPython',
        'jedi',
        'parso',
    ],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='pyhelloworld',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=None,  # Add path to .ico file here if you have one
)