import platform
import subprocess
from pathlib import Path


def test_compiled() -> None:
    """Test that the PyInstaller-bundled executable outputs 'Hello world'."""
    # Skip on non-Windows platforms
    assert platform.system() == "Windows", (
        "Test only runs on Windows")

    # Define the executable path (onefile mode: dist/pyhelloworld.exe)
    exe_path = Path(__file__).parent.parent / "dist" / "pyhelloworld.exe"

    # Skip if executable doesn't exist
    assert exe_path.exists(), (
        f"Executable not found at {exe_path}")

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

