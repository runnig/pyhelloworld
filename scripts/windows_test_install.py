#!/usr/bin/env python3
"""Install test installer and run pytest tests."""

import os
import subprocess
import sys
from pathlib import Path


def verify_installer():
    """Build test installer if it doesn't exist."""
    test_installer = Path("dist/pyhelloworld-test-installer.exe")
    assert test_installer.exists(), f"{test_installer} does not exist"


def install_test_installer() -> bool:
    """Install test installer silently to TEMP directory."""
    installer_path = Path("dist/pyhelloworld-test-installer.exe")
    install_dir = Path(os.environ.get("TEMP", "")) / "pyhelloworld"

    print(f"Installing to: {install_dir}")
    print(f"Installer: {installer_path} (user-level, no UAC)")

    result = subprocess.run(
        [str(installer_path), "/S", f"/D={install_dir}"],
        capture_output=True,
        text=True,
        check=False,
    )

    if result.returncode != 0:
        print(f"[x] Installation failed with exit code: {result.returncode}")
        print("Output:")
        print(result.stdout)
        print(result.stderr)
        return False

    installed_exe = install_dir / "pyhelloworld.exe"
    if not installed_exe.exists():
        print(f"[x] Installed executable not found at: {installed_exe}")
        return False

    print(f"[v] Installation successful: {installed_exe}")
    return True


def main() -> int:
    print("Running Windows test installation...")

    try:
        verify_installer()
    except Exception:
        return 1

    if not install_test_installer():
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
