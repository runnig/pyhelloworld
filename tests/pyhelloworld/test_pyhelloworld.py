import argparse
import platform
import subprocess
from pathlib import Path
from typing import Any

import pytest

from pyhelloworld import health, main


def test_main(capsys: Any) -> None:
    """Test that main function prints the expected output with data path."""
    data_path = Path(__file__).parent.parent.parent / "data" / "data.txt"
    args = argparse.Namespace(data_path=str(data_path))
    main(args)
    captured = capsys.readouterr()
    # Check for either development or bundled mode output
    output = captured.out.strip()
    assert "Hello world" in output


def test_health() -> None:
    """Test health function returns expected status."""
    assert "ok" == health()


def test_bundled_executable_output() -> None:
    """Test that the PyInstaller-bundled executable outputs 'Hello world'."""
    # Skip on non-Windows platforms
    if platform.system() != "Windows":
        pytest.skip("Test only runs on Windows")

    # Define the executable path (onefile mode: dist/pyhelloworld.exe)
    exe_path = Path(__file__).parent.parent.parent / "dist" / "pyhelloworld.exe"

    # Skip if executable doesn't exist
    if not exe_path.exists():
        pytest.skip(f"Executable not found at {exe_path}")

    # Run the executable
    result = subprocess.run(
        [str(exe_path), "--data-path", "data.txt"],
        capture_output=True,
        text=True,
        check=True,
    )

    # Get the first line of output
    output_lines = result.stdout.strip().split("\n")
    first_line = output_lines[0]

    # Assert the first line is exactly "Hello world"
    assert first_line == "Hello world", (
        f"Expected 'Hello world', got: {first_line}"
    )
