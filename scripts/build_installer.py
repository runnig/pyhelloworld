"""Build NSIS installer for pyhelloworld."""

import argparse
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path


def find_makensis() -> Path:
    """Find makensis.exe executable.

    Checks MAKENSIS_PATH environment variable first, then PATH.
    """
    # Check MAKENSIS_PATH environment variable
    makensis_path = os.environ.get("MAKENSIS_PATH")
    if makensis_path:
        path = Path(makensis_path)
        if path.exists():
            return path

    # Search in PATH
    makensis = shutil.which("makensis.exe")
    if not makensis:
        raise RuntimeError("makensis.exe not found")

    return Path(makensis)


def parse_makensis_version(makensis_path: Path) -> str:
    """Check makensis.exe version (requires >= 3.11).

    Returns version string, or None if unable to determine.
    """
    result = subprocess.run(
        [str(makensis_path), "/VERSION"],
        capture_output=True,
        text=True,
        check=False,
    )
    version_output = result.stdout + result.stderr

    match = re.search(r"(\d+\.\d+)", version_output)
    if match:
        return match.group(1)
    return ""


def build_pyinstaller_executable() -> bool:
    """Build PyInstaller executable using make."""
    result = subprocess.run(
        ["make", "windows-build"],
        check=False,
    )
    return result.returncode == 0


def is_up_to_date(installer_path: Path, nsi_path: Path, exe_path: Path) -> bool:
    """Check if installer is up to date based on file modification times."""
    if not installer_path.exists():
        return False

    installer_time = installer_path.stat().st_mtime
    nsi_time = nsi_path.stat().st_mtime
    exe_time = exe_path.stat().st_mtime

    return installer_time > nsi_time and installer_time > exe_time


def build_installer(
    makensis_path: Path,
    nsi_path: Path,
    output_path: Path,
    test_mode: bool = False,
) -> bool:
    """Build NSIS installer.

    Args:
        makensis_path: Path to makensis.exe
        nsi_path: Path to .nsi file
        output_path: Expected output installer path
        test_mode: If True, build with TEST_MODE=1

    Returns:
        True if build succeeded, False otherwise
    """
    cmd = [str(makensis_path)]
    if test_mode:
        cmd.extend(["/DTEST_MODE=1"])
    cmd.append(str(nsi_path))

    result = subprocess.run(cmd, capture_output=True, text=True, check=False)

    if result.returncode != 0:
        print(f"[x] makensis.exe failed with exit code: {result.returncode}")
        print("Output:")
        print(result.stdout)
        print(result.stderr)
        return False

    if not output_path.exists():
        print(f"[x] Installer not created at expected location: {output_path}")
        return False

    size_kb = output_path.stat().st_size / 1024
    print(f"[v] {output_path}")
    print(f"    Size: {size_kb:.2f} KB")

    return True


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Build NSIS installer for pyhelloworld"
    )
    parser.add_argument(
        "--test",
        action="store_true",
        help="Build test installer (user-level, no UAC)",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Force rebuild even if up to date",
    )
    args = parser.parse_args()

    # Paths
    nsi_path = Path("installer/pyhelloworld.nsi")
    if test_mode := args.test:
        output_path = Path("dist/pyhelloworld-test-installer.exe")
    else:
        output_path = Path("dist/pyhelloworld-installer.exe")
    exe_path = Path("dist/pyhelloworld.exe")

    # Find makensis
    makensis_path = find_makensis()
    if not makensis_path:
        print("[x] Error: makensis.exe not found")
        print("Please install NSIS from https://nsis.sourceforge.io/")
        if "MAKENSIS_PATH" in os.environ:
            print(f"MAKENSIS_PATH is set to: {os.environ['MAKENSIS_PATH']}")
        else:
            print(
                "Set MAKENSIS_PATH to point to makensis.exe, or add NSIS to your PATH."
            )
        return 1

    print(f"[v] Found makensis.exe at: {makensis_path}")

    # Check makensis version
    version = parse_makensis_version(makensis_path)
    if version:
        version_parts = [int(x) for x in version.split(".")]
        min_version = [3, 11]
        if version_parts < min_version:
            print(f"[x] makensis.exe version {version} is too old")
            print("Minimum required version: 3.11")
            print("Please upgrade NSIS from https://nsis.sourceforge.io/")
            return 1
        print(f"[v] makensis.exe version: {version} (>= 3.11)")
    else:
        print("[!] Warning: Could not determine makensis.exe version")

    # Ensure PyInstaller executable exists
    if not exe_path.exists():
        print("PyInstaller executable not found. Building first...")
        if not build_pyinstaller_executable():
            print("[x] Failed to build PyInstaller executable")
            return 1

    # Check if rebuild needed
    if not args.force and is_up_to_date(output_path, nsi_path, exe_path):
        print(f"Installer is up to date: {output_path}")
        return 0

    print("Rebuilding installer (dependencies changed)...")

    # Build installer
    mode_desc = "(user-level, no UAC)" if test_mode else "(admin-level)"
    print(f"Creating installer using makensis.exe {mode_desc}...")
    print(f"NSI file: {nsi_path}")
    print(f"Output: {output_path}")

    if not build_installer(makensis_path, nsi_path, output_path, test_mode):
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
