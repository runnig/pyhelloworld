
## Windows Install

```
# install uv
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# create virtual environment
uv venv

# activate virtual environment
.venv\Scripts\activate.bat

# install dependencies
make sync
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
make windows-compile

# Build Windows installer (admin-level, HKLM registry, requires NSIS 3.11+)
make windows-installer

# Build test installer (user-level, no UAC, HKCU registry, requires NSIS 3.11+)
make windows-run-installer-test

# Install test installer silently to TEMP directory
make windows-test-installed

# Run pytest tests on installed executable
make windows-test-install
```

### Version Requirements

The installer build requires NSIS version 3.11 or higher. The script will automatically check the version and fail if it's too old.

### Adding NSIS to PATH (Optional)

To avoid setting `MAKENSIS_PATH` every time, you can add NSIS to your system PATH:

**PowerShell (temporary):**
```powershell
$env:PATH += ";g:\nsis"
```

**PowerShell (permanent):**
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
make sync
```
