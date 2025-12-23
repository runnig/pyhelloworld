# pyhelloworld

A demonstration project for building Python Windows applications with PyInstaller and NSIS installers. This project shows best practices for creating distributable Python applications that work seamlessly in both development and bundled environments.

## Features

- **Dual-mode execution**: Works in development and as a PyInstaller-bundled executable
- **Smart path resolution**: Automatically handles data file paths for both environments
- **Windows installers**: Two installer types via NSIS:
  - Admin-level (HKLM registry) - requires elevation
  - User-level (HKCU registry) - no elevation required
- **Comprehensive testing**: Tests for source, compiled, and installed executables
- **Modern tooling**: Built with uv, tested with pytest, type-checked with basedpyright

## Repository Structure

```
pyhelloworld/
├── src/pyhelloworld/      # Main application source code
│   ├── pyhelloworld.py     # CLI application with path resolution
│   └── paths.py            # Path utilities for dev/bundled modes
├── scripts/                # Build and installation scripts
│   ├── build_installer.py  # NSIS installer builder
│   └── windows_test_install.py  # Test installation utilities
├── data/                   # Application data files
│   └── data.txt            # Sample data file
├── tests/                  # Test suite
│   ├── pyhelloworld/       # Unit tests
│   ├── test_compiled.py    # Bundled executable tests
│   └── test_installed.py   # Installed executable tests
├── installer/              # NSIS installer configuration
│   └── pyhelloworld.nsi    # Installer script
├── docs/                   # Additional documentation
│   └── pyinstaller-windows-best-practices.md
├── pyhelloworld.spec       # PyInstaller configuration
├── Makefile                # Build and development commands
└── pyproject.toml          # Project configuration and dependencies
```

## Quick Start

### Installation

```bash
# Install uv (Python package manager)
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# Create virtual environment
uv venv

# Activate virtual environment
.venv\Scripts\activate.bat

# Install all dependencies (including dev tools)
make sync-all
```

### Basic Usage

```bash
# Run the application
make run
# or
uv run pyhelloworld

# Run with custom data path
uv run pyhelloworld --data-path ./data/data.txt

# Get help
uv run pyhelloworld --help

```

## Usage

The application reads a data file and prints a greeting:

```bash
$ uv run pyhelloworld
Hello world
(Running from development environment)
```

When built as an executable, the output shows:

```bash
$ dist\pyhelloworld.exe
Hello world
(Running from bundled application)
```

## Development

```bash
# Run tests
make test

# Run specific test file
uv run pytest -x -n 1 -v -s tests/pyhelloworld/test_pyhelloworld.py

# Lint code
make lint

# Format code
make format

# Type check
make typecheck

# Clean build artifacts
make clean
```

## Windows Install

### Setting up NSIS

Building the Windows installer requires [NSIS (Nullsoft Scriptable Install System)](https://nsis.sourceforge.io/).

If `makensis.exe` is in your system PATH, you can build the installer directly:

```bash
make windows-build-installer-admin
```

If `makensis.exe` is installed in a custom location (not in PATH), set `MAKENSIS_PATH`:

```bash
# For g:\nsis (example)
set MAKENSIS_PATH=g:\nsis\makensis.exe
make windows-build-installer-admin

# Or in one command:
MAKENSIS_PATH=g:\nsis\makensis.exe make windows-build-installer-admin
```

**Example installations:**

- **Default installation**: `C:\Program Files\NSIS\makensis.exe` (usually in PATH)
- **Custom**: `C:\tools\nsis\makensis.exe` → `set MAKENSIS_PATH=C:\tools\nsis\makensis.exe`

### Build Commands

```bash
# Build Windows executable
# Runs Pyinstaller. Outputs dist\pyhelloworld.exe
make windows-compile

# Runs a Python test to verify that the built executable
# dist\pyhelloworld.exe outputs the correct string
make windows-test-compiled

# Build Windows installer (admin-level, HKLM registry, requires NSIS 3.11+)
# Runs NSIS (makensis.exe). Outputs dist\pyhelloworld-installer.exe
make windows-build-installer-admin

# Builds a user-level test installer.
# Does not require Admin to install:
# no UAC, HKCU registry, requires NSIS 3.11+
make windows-build-installer-test

# Runs the installed binary and checks the output
make windows-test-installed
```

### Version Requirements

The installer build requires NSIS version 3.11 or higher. The script will automatically check the version and fail if it's too old.

### Adding NSIS to PATH (Optional)

To avoid setting `MAKENSIS_PATH` every time, you can add NSIS to your system PATH:

**Control Panel**
Add to your user or system environment variables in Control Panel.

**Command Prompt (temporary):**
```cmd
set PATH=%PATH%;g:\nsis
```

## Linux Install

Follow the instructions here: https://docs.astral.sh/uv/getting-started/installation/

```bash
# Create virtual environment
uv venv

# Activate virtual environment
.venv/bin/activate

# Install dependencies
make sync-all
```

**Warning**: PyInstaller only builds the "native" binaries;
if Pyinstaller has built a binary on Linux, it won't run on Windows.
