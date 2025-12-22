param(
    [string]$Target = "help"
)

function Show-Help {
    Write-Host "Available commands:"
    Write-Host "  windows-installer  Create Windows installer (builds executable if needed)"
    Write-Host "  windows-install  Install Windows application to target directory"
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

function Invoke-WindowsInstall {
    param(
        [string]$InstallDir = (Join-Path $env:TEMP "pyhelloworld-test")
    )

    $installerPath = "dist\pyhelloworld-installer.exe"

    # Check if installer exists, build if needed
    if (-not (Test-Path $installerPath)) {
        Write-Host "Installer not found at $installerPath. Creating installer first..."
        Invoke-WindowsInstaller
    } else {
        Write-Host "Using existing installer: $installerPath"
    }

    # Create installation directory if it doesn't exist
    if (-not (Test-Path $InstallDir)) {
        Write-Host "Creating installation directory: $InstallDir"
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    }

    Write-Host "Starting unattended installation to: $InstallDir"
    Write-Host "Installer: $installerPath"

    try {
        # Run unattended installation
        $installArgs = @("/S", "/D=$InstallDir")
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList $installArgs -Wait -PassThru

        if ($installProcess.ExitCode -eq 0) {
            Write-Host "[v] Installation completed successfully"

            # Verify installation
            $exePath = Join-Path $InstallDir "pyhelloworld.exe"

            if (Test-Path $exePath) {
                Write-Host "[v] Verification: Executable found at $exePath"

                # Check registry entry
                $regPath = "HKLM:\Software\HelloWorld"
                if (Test-Path $regPath) {
                    $regInstallPath = (Get-ItemProperty -Path $regPath -Name "InstallPath").InstallPath
                    Write-Host "[v] Verification: Registry entry found: $regInstallPath"
                }

                Write-Host "Installation verified successfully!"
            } else {
                Write-Host "[x] Warning: Executable not found at expected location: $exePath"
                exit 1
            }
        } else {
            Write-Host "[x] Installation failed with exit code: $($installProcess.ExitCode)"
            exit 1
        }
    } catch {
        Write-Host "[x] Error during installation: $_"
        exit 1
    }
}

function Invoke-WindowsRun {
    param(
        [string]$InstallDir = (Join-Path $env:TEMP "pyhelloworld-test")
    )

    $exePath = Join-Path $InstallDir "pyhelloworld.exe"

    # Verify executable exists, fallback to dist if not installed
    if (-not (Test-Path $exePath)) {
        Write-Host "[!] Warning: Installed executable not found at $exePath"
        $fallbackExe = "dist\pyhelloworld.exe"

        if (Test-Path $fallbackExe) {
            Write-Host "[*] Using fallback executable from: $fallbackExe"
            $exePath = $fallbackExe
            $exeDir = Split-Path -Parent $exePath
        } else {
            Write-Host "[x] Error: No executable found at installed location or fallback"
            Write-Host "Run 'make windows-install' first to install the application."
            exit 1
        }
    } else {
        $exeDir = Split-Path -Parent $exePath
    }

    Write-Host "Running application from: $exePath"
    Write-Host "Working directory: $exeDir"
    Write-Host "Command: $exePath --data-path data.txt"
    Write-Host "--- Output ---"

    try {
        # Run installed application and capture output
        $currentDir = Get-Location
        Set-Location $exeDir
        $output = & $exePath --data-path data.txt 2>&1
        Set-Location $currentDir

        Write-Host $output

        # Verify output contains expected content
        if ($output -match "Hello world") {
            Write-Host "--- Verification ---"
            Write-Host "[v] SUCCESS: Application output verified correctly"
            Write-Host "[v] Data file is accessible"
            Write-Host "[v] Bundled application is functioning"

            # Check if running from bundled application
            if ($output -match "bundled application") {
                Write-Host "[v] Application correctly detected bundled mode"
            }

            exit 0
        } else {
            Write-Host "--- Verification ---"
            Write-Host "[x] FAILURE: Expected output not found"
            Write-Host "Expected to contain: 'Hello world'"
            Write-Host "Actual output: '$output'"
            exit 1
        }

    } catch {
        Write-Host "[x] Error running application: $_"
        exit 1
    }
}

function Invoke-WindowsAll {
    Invoke-WindowsInstaller
    Write-Host "Windows build complete!"
    Write-Host "Executable: dist\pyhelloworld.exe"
    Write-Host "Installer: dist\pyhelloworld-installer.exe"
}

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
