param(
    [string]$Target = "help"
)

function Show-Help {
    Write-Host "Available commands:"
    Write-Host "  sync           Sync the package"
    Write-Host "  sync-all       Sync development dependencies"
    Write-Host "  test           Run tests"
    Write-Host "  run            Run the main script"
    Write-Host "  lint           Run linting"
    Write-Host "  format         Format code"
    Write-Host "  typecheck      Type check code"
    Write-Host "  clean          Clean build artifacts"
    Write-Host "  build          Build the package"
    Write-Host "  windows-build  Build Windows executable with PyInstaller"
    Write-Host "  windows-installer  Create Windows installer"
    Write-Host "  windows-all    Complete Windows build and installer"
}

function Invoke-Sync {
    uv sync
}

function Invoke-SyncAll {
    uv sync --all-groups
}

function Invoke-Test {
    uv run pytest tests/ -v
}

function Invoke-Run {
    uv run pyhelloworld --data-path ./data/data.txt
}

function Invoke-Lint {
    uv run ruff check src/ tests/
    uv run basedpyright src/ tests/
}

function Invoke-Format {
    uv run ruff format src/ tests/
}

function Invoke-Typecheck {
    uv run basedpyright src/ tests/
}

function Invoke-Clean {
    if (Test-Path "build") { Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue }
    if (Test-Path "dist") { Remove-Item -Path "dist" -Recurse -Force -ErrorAction SilentlyContinue }
    Get-ChildItem -Path . -Filter "*.egg-info" -Directory | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path . -Recurse -Directory -Name "__pycache__" | ForEach-Object { Remove-Item -Path $_ -Recurse -Force -ErrorAction SilentlyContinue }
    Get-ChildItem -Path . -Recurse -Filter "*.pyc" | Remove-Item -Force -ErrorAction SilentlyContinue
}

function Invoke-CleanPyinstaller {
    if (Test-Path "build") { Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue }
    if (Test-Path "dist") { Remove-Item -Path "dist" -Recurse -Force -ErrorAction SilentlyContinue }
    Get-ChildItem -Path . -Filter "*.spec" | Remove-Item -Force -ErrorAction SilentlyContinue
}

function Invoke-Build {
    Invoke-Clean
    uv build
}

function Invoke-WindowsBuild {
    $env:PYTHONPATH = "$PWD;$PWD\src"
    $env:PATH = "$env:PATH;g:\nsis"
    Invoke-CleanPyinstaller
    if (-not (Test-Path "pyhelloworld.spec")) {
        Write-Host "Generating spec file..."
        uv run pyi-makespec src/pyhelloworld/pyhelloworld.py
        # Update the generated spec file with our custom settings
        $specContent = Get-Content "pyhelloworld.spec"
        $specContent = $specContent -replace "pathex=\[\]", "pathex=['src']"
        $specContent = $specContent -replace "datas=\[\]", "datas=[('data\\data.txt', '.')]"
        $specContent = $specContent -replace "hiddenimports=\[\]", "hiddenimports=['pyhelloworld.paths']"
        $specContent | Set-Content "pyhelloworld.spec"
    }
    uv run pyinstaller pyhelloworld.spec --clean
}

function Invoke-WindowsTest {
    Invoke-WindowsBuild
    Write-Host "Testing bundled executable..."
    Set-Location "dist\pyhelloworld"
    .\pyhelloworld.exe --data-path data.txt
    Set-Location "..\.."
}

function Invoke-WindowsInstaller {
    $env:PYTHONPATH = "$PWD;$PWD\src"
    $env:PATH = "$env:PATH;g:\nsis"
    Invoke-WindowsBuild

    if (Get-Command iscc -ErrorAction SilentlyContinue) {
        Write-Host "Creating Inno Setup installer..."
        iscc build\pyhelloworld.iss
    }
    elseif (Get-Command makensis -ErrorAction SilentlyContinue) {
        Write-Host "Creating NSIS installer..."
        makensis build\pyhelloworld.nsi
    }
    else {
        Write-Host "Error: Neither Inno Setup (iscc) nor NSIS (makensis) found."
        Write-Host "Install one of them and try again."
        exit 1
    }
}

function Invoke-WindowsAll {
    Invoke-WindowsInstaller
    Write-Host "Windows build complete!"
    Write-Host "Executable bundle: dist\pyhelloworld\"
    Write-Host "Installer: dist\pyhelloworld-0.1.0-setup.exe"
}

# Main execution
switch ($Target.ToLower()) {
    "help" { Show-Help }
    "sync" { Invoke-Sync }
    "sync-all" { Invoke-SyncAll }
    "test" { Invoke-Test }
    "run" { Invoke-Run }
    "lint" { Invoke-Lint }
    "format" { Invoke-Format }
    "typecheck" { Invoke-Typecheck }
    "clean" { Invoke-Clean }
    "build" { Invoke-Build }
    "windows-build" { Invoke-WindowsBuild }
    "windows-test" { Invoke-WindowsTest }
    "windows-installer" { Invoke-WindowsInstaller }
    "windows-all" { Invoke-WindowsAll }
    default {
        Write-Host "Unknown target: $Target"
        Show-Help
        exit 1
    }
}
