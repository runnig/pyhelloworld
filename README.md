
## Windows Install

```
# install uv
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# create virtual environment
uv venv

# activate virtual environment
.venv\Scripts\activate.bat

# install dependencies
make sync-all
```

## Windows Installer

Building the Windows installer requires [NSIS (Nullsoft Scriptable Install System)](https://nsis.sourceforge.io/).

### Setting up NSIS

If `makensis.exe` is in your system PATH, you can build the installer directly:

```bash
make windows-installer
```

If `makensis.exe` is installed in a custom location (not in PATH), set `MAKENSIS_PATH`:

```bash
# For g:\nsis (example)
set MAKENSIS_PATH=g:\nsis\makensis.exe
make windows-installer

# Or in one command:
MAKENSIS_PATH=g:\nsis\makensis.exe make windows-installer
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
make windows-test-compled

# Build Windows installer (admin-level, HKLM registry, requires NSIS 3.11+)
# Runs NSIS (makensis.exe). Outputs dist\pyhelloworld-installer.exe
make windows-installer

# Builds a user-level test installer.
# Does not require Admin to install:
# no UAC, HKCU registry, requires NSIS 3.11+
make windows-run-installer-test

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


## Linux install

Follow the instructions here: https://docs.astral.sh/uv/getting-started/installation/

```
# create virtual environment
uv venv

# activate virtual environment
.venv/bin/activate

# install dependencies
make sync-all
```

**Warning**: PyInstaller only builds the "native" binaries;
if Pyinstaller has built a binary on Linux, it won't run on Windows.
