param(
    [string]$Target = "help"
)

function Show-Help {
    Write-Host "Available commands:"
    Write-Host "  windows-installer  Create Windows installer (builds executable if needed)"
    Write-Host "  windows-install  Install Windows application to target directory"
    Write-Host "  windows-test-install  Install and test Windows application"
    Write-Host "  windows-run    Run installed Windows application and verify output"
    Write-Host "  windows-all    Complete Windows build and installer"
}

function Invoke-WindowsInstaller {
    $nsiFile = "installer\pyhelloworld.nsi"
    $installerOutput = "dist\pyhelloworld-installer.exe"
    $exeOutput = "dist\pyhelloworld.exe"

    # Check if makensis.exe is installed (use MAKENSIS_PATH if set, otherwise check PATH)
    $makensisPath = if ($env:MAKENSIS_PATH) {
        Get-Command $env:MAKENSIS_PATH -ErrorAction SilentlyContinue
    } else {
        Get-Command "makensis.exe" -ErrorAction SilentlyContinue
    }

    if (-not $makensisPath) {
        Write-Host "[x] Error: makensis.exe not found"
        Write-Host "Please install NSIS from https://nsis.sourceforge.io/"
        if ($env:MAKENSIS_PATH) {
            Write-Host "MAKENSIS_PATH is set to: $($env:MAKENSIS_PATH)"
        } else {
            Write-Host "Set MAKENSIS_PATH to point to makensis.exe, or add NSIS to your PATH."
        }
        exit 1
    }

    Write-Host "[v] Found makensis.exe at: $($makensisPath.Source)"

    # Check makensis.exe version (requires at least 3.11)
    try {
        $versionOutput = & $makensisPath.Source /VERSION 2>&1
        if ($versionOutput -match '(\d+\.\d+)') {
            $version = [version]$matches[1]
            $minimumVersion = [version]"3.11"

            if ($version -lt $minimumVersion) {
                Write-Host "[x] makensis.exe version $version is too old"
                Write-Host "Minimum required version: 3.11"
                Write-Host "Please upgrade NSIS from https://nsis.sourceforge.io/"
                exit 1
            }

            Write-Host "[v] makensis.exe version: $version (>= 3.11)"
        } else {
            Write-Host "[!] Warning: Could not determine makensis.exe version"
        }
    } catch {
        Write-Host "[!] Warning: Failed to check makensis.exe version: $_"
    }

    # Check if the PyInstaller executable exists and is up to date
    if (-not (Test-Path $exeOutput)) {
        Write-Host "PyInstaller executable not found. Building first..."
        & make windows-build
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[x] Failed to build PyInstaller executable"
            exit 1
        }
    }

    $nsiFileObj = Get-Item $nsiFile
    $exeFileObj = Get-Item $exeOutput

    if (Test-Path $installerOutput) {
        $installerFileObj = Get-Item $installerOutput

        if ($installerFileObj.LastWriteTime -gt $nsiFileObj.LastWriteTime -and $installerFileObj.LastWriteTime -gt $exeFileObj.LastWriteTime) {
            Write-Host "Installer is up to date: $installerOutput"
            Write-Host "NSI file: $($nsiFileObj.LastWriteTime)"
            Write-Host "Installer: $($installerFileObj.LastWriteTime)"
            return
        } else {
            Write-Host "Rebuilding installer (dependencies changed)..."
        }
    }

    Write-Host "Creating Windows installer using makensis.exe..."
    Write-Host "NSI file: $nsiFile"
    Write-Host "Output: $installerOutput"

    # Run makensis.exe
    $makensisResult = & $makensisPath.Source $nsiFile 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Host "[x] makensis.exe failed with exit code: $LASTEXITCODE"
        Write-Host "Output:"
        Write-Host $makensisResult
        exit 1
    }

    if (-not (Test-Path $installerOutput)) {
        Write-Host "[x] Installer not created at expected location: $installerOutput"
        exit 1
    }

    $installerFileObj = Get-Item $installerOutput
    Write-Host "[v] Installer created successfully: $installerOutput"
    Write-Host "Size: $([math]::Round($installerFileObj.Length / 1KB, 2)) KB"
    Write-Host "Created: $($installerFileObj.LastWriteTime)"
}

function Invoke-WindowsTestInstall {
    param(
        [string]$InstallDir = (Join-Path $env:TEMP "pyhelloworld-test")
    )

    Write-Host "Running full installation test..."

    # First, ensure installation
    Invoke-WindowsInstall -InstallDir $InstallDir

    if ($LASTEXITCODE -ne 0) {
        Write-Host "[x] Installation failed, cannot test"
        exit 1
    }

    # Test installed executable
    $exePath = Join-Path $InstallDir "pyhelloworld.exe"

    if (-not (Test-Path $exePath)) {
        Write-Host "[x] Executable not found: $exePath"
        exit 1
    }

    Write-Host "Testing installed executable..."
    $output = & $exePath --data-path data.txt 2>&1

    if ($output -match "Hello world") {
        Write-Host "[v] Executable runs correctly"
        Write-Host "Output: $output"

        # Verify data.txt is bundled correctly
        if ($output -match "bundled application") {
            Write-Host "[v] Data file accessible in bundled mode"
        }
    } else {
        Write-Host "[x] Executable failed to run or wrong output"
        Write-Host "Expected: 'Hello world'"
        Write-Host "Got: $output"
        exit 1
    }

    # Verify all components
    Write-Host "Verifying installed components..."

    # Check executable
    if (Test-Path $exePath) {
        Write-Host "[v] Executable installed"
    } else {
        Write-Host "[x] Executable missing"
        exit 1
    }
    "windows-test-install" { Invoke-WindowsTestInstall }
    "windows-install" {
        $installDir = $env:INSTALL_DIR
        if ($installDir) {
            Invoke-WindowsInstall -InstallDir $installDir
        } else {
            Invoke-WindowsInstall
        }
    }
    "windows-run" {
        $installDir = $env:INSTALL_DIR
        if ($installDir) {
            Write-Host "Using custom install directory: $installDir"
            Invoke-WindowsRun -InstallDir $installDir
        } else {
            Write-Host "Using default install directory"
            Invoke-WindowsRun
        }
    }
    "windows-all" { Invoke-WindowsAll }
    default {
        Write-Host "Unknown target: $Target"
        Show-Help
        exit 1
    }
}

    # Check registry

# Main execution
switch ($Target.ToLower()) {
    "help" { Show-Help }
    "windows-installer" { Invoke-WindowsInstaller }
    "windows-install" {
        $installDir = $env:INSTALL_DIR
        if ($installDir) {
            Invoke-WindowsInstall -InstallDir $installDir
        } else {
            Invoke-WindowsInstall
        }
    }
    "windows-test-install" { Invoke-WindowsTestInstall }
    default {
        Write-Host "Unknown target: $Target"
        Show-Help
        exit 1
    }
}
