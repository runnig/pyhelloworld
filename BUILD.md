# Build Instructions for PyInstaller Windows Distribution

This document provides step-by-step instructions for building Windows installers using the provided configuration files.

## Prerequisites

1. **Python 3.8+** with uv package manager
2. **Windows** (10/11 recommended for testing)
3. **Inno Setup** (for installer creation) - Download from [jrsoftware.org](https://jrsoftware.org/isinfo.php)

## Quick Start

### 1. Initial Setup

```bash
# Clone and set up the project
git clone <your-repo>
cd pyhelloworld

# Install dependencies
make sync-all

# Test in development mode
make run
```

### 2. Test Path Resolution

```bash
# Verify path resolution works correctly
make windows-test-path
```

### 3. Build Windows Executable

```bash
# Complete Windows build with installer
make windows-all
```

## Manual Build Steps

### Step 1: Create Icon and Branding

1. Create `assets/icon.ico` (256x256, 32x32, 16x16 sizes)
2. Edit `build/version_info.txt` with your company information
3. Update `build/pyhelloworld.iss` with your details

### Step 2: Build with PyInstaller

```bash
# Add PyInstaller to development dependencies
uv add --dev pyinstaller

# Build the application
uv run pyinstaller pyhelloworld.spec --clean --noconfirm

# Test the executable
cd dist/pyhelloworld
./pyhelloworld.exe
```

### Step 3: Create Installer

```bash
# Create Inno Setup installer
iscc build/pyhelloworld.iss

# The installer will be created as:
# pyhelloworld-0.1.0-setup.exe
```

## File Structure After Build

```
pyhelloworld/
├── assets/
│   └── icon.ico                 # Application icon
├── build/
│   ├── version_info.txt        # Version information
│   ├── pyhelloworld.iss         # Inno Setup script
│   └── pyhelloworld.nsi         # NSIS script (alternative)
├── dist/
│   └── pyhelloworld/           # One-dir distribution
│       ├── pyhelloworld.exe     # Main executable
│       ├── data.txt            # Bundled data file
│       ├── _internal/          # PyInstaller internals
│       └── ...                 # Dependencies
├── pyhelloworld-0.1.0-setup.exe  # Windows installer
└── pyhelloworld.spec            # PyInstaller configuration
```

## Testing Checklist

### Application Testing

- [ ] Executable starts without errors
- [ ] Data file is accessible
- [ ] Command line arguments work:
  ```bash
  pyhelloworld.exe --help
  pyhelloworld.exe --version
  ```
- [ ] Error messages are user-friendly
- [ ] Application works from different directories

### Installer Testing

- [ ] Installer runs on clean Windows machine
- [ ] Installation completes successfully
- [ ] Start Menu shortcuts are created
- [ ] Desktop shortcut works (if selected)
- [ ] Application launches from shortcuts
- [ ] Uninstaller removes all files
- [ ] Add/Remove Programs entry is correct

### Cross-Version Testing

- [ ] Windows 10 (multiple builds)
- [ ] Windows 11
- [ ] Both x64 and x86 architectures
- [ ] Admin and non-admin users
- [ ] Antivirus compatibility (Windows Defender, etc.)

## Troubleshooting

### Common Issues

1. **Module Not Found Errors**
   - Add to `hiddenimports` in spec file
   - Check hookspath configuration

2. **Data File Not Found**
   - Verify path resolution in paths.py
   - Check data file is included in spec file

3. **Icon Not Applied**
   - Ensure icon.ico is valid format
   - Check file permissions

4. **Installer Fails**
   - Verify Inno Setup is installed
   - Check script syntax

### Debug Commands

```bash
# Test path resolution
python src/pyhelloworld/paths.py

# Verbose PyInstaller build
uv run pyinstaller --clean --noconfirm --log-level DEBUG pyhelloworld.spec

# Test executable with debug output
cd dist/pyhelloworld && ./pyhelloworld.exe --help
```

## Optimization

### Reducing Bundle Size

1. **Exclude unnecessary modules** in spec file:
   ```python
   excludes=['tkinter', 'matplotlib', 'PyQt5', 'PyQt6']
   ```

2. **Use UPX compression**:
   ```python
   upx=True  # In EXE and COLLECT
   ```

3. **Remove debug symbols**:
   ```python
   strip=True
   ```

### Performance Optimization

1. **One-dir mode** for faster startup
2. **Path caching** for frequently accessed files
3. **Lazy loading** for optional modules

## Production Deployment

### Code Signing (Recommended)

1. Obtain code signing certificate
2. Sign the executable:
   ```bash
   signtool sign /f certificate.pfx /p password dist/pyhelloworld/pyhelloworld.exe
   ```
3. Sign the installer:
   ```bash
   signtool sign /f certificate.pfx /p password pyhelloworld-0.1.0-setup.exe
   ```

### Distribution

1. **Checksum**: Generate SHA256 checksums
2. **Documentation**: Include README and installation guide
3. **Version Management**: Semantic versioning
4. **Update Strategy**: Plan for automatic updates

## Next Steps

1. **Customize Branding**: Update all company/product information
2. **Add Error Handling**: Implement comprehensive error reporting
3. **Add Logging**: Include application logging
4. **User Documentation**: Create user manual
5. **Support Channel**: Set up user support process