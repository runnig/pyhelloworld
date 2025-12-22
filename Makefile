# Variables
BASE_NAME = pyhelloworld
SPEC_FILE = $(BASE_NAME).spec
SRCS = src/$(BASE_NAME)/$(BASE_NAME).py
DATA_FILES = data/*
CONFIG_FILES = pyproject.toml
PYINSTALLER_OUTPUT_EXE = dist/$(BASE_NAME).exe
INSTALLER_OUTPUT = dist/$(BASE_NAME)-installer.exe
SPACE = $(empty) $(empty)
empty =

# NSIS installer path (optional, set if makensis.exe is not in PATH)
MAKENSIS_PATH ?=

# Suppress command echoing for cleaner output
.SILENT:

.PHONY: help sync sync-all test run lint format typecheck clean build windows-build windows-installer windows-test-install windows-dev-test windows-status


# Default target
help:
	@echo "Available commands:"
	@echo "  sync           Sync the package"
	@echo "  sync-all       Sync development dependencies"
	@echo "  test           Run tests"
	@echo "  run            Run the main script"
	@echo "  lint           Run linting"
	@echo "  format         Format code"
	@echo "  typecheck      Type check code"
	@echo "  clean          Clean build artifacts"
	@echo "  build          Build the package"
	@echo "  windows-dev-test  Build and test Windows executable with data files"
	@echo "  windows-build  Build Windows executable with PyInstaller"
	@echo "  windows-installer  Create Windows installer"
	@echo "  windows-test-install  Install and test Windows application"
	@echo "  windows-install  Install Windows application to target directory"
	@echo "  windows-run    Run installed Windows application and verify output"

# sync the package and dependencies
sync:
	uv sync --active

# sync development dependencies
sync-all:
	uv sync --all-groups

# Run tests
test:
	uv run pytest tests/ -v

# Run the main script
run:
	uv run pyhelloworld --data-path ./data/data.txt

# Lint code
lint:
	uv run ruff check src/ tests/
	uv run basedpyright src/ tests/

# Format code
format:
	uv run ruff format src/ tests/

# Type check code
typecheck:
	uv run basedpyright src/ tests/

# Clean build artifacts
clean:
	rm -rf build dist *.egg-info

# Windows build targets implemented directly in Makefile
windows-build: $(PYINSTALLER_OUTPUT_EXE)

 $(PYINSTALLER_OUTPUT_EXE): $(SRCS) $(DATA_FILES) $(CONFIG_FILES)
	@echo Building $(PYINSTALLER_OUTPUT_EXE) - dependencies changed
	uv run pyinstaller "$(SPEC_FILE)" --clean
	@powershell.exe -Command "if (!(Test-Path '$(PYINSTALLER_OUTPUT_EXE)')) { Write-Host 'Error: Build failed - executable not found at $(PYINSTALLER_OUTPUT_EXE)'; exit 1 }"
	@echo Build completed successfully: $(PYINSTALLER_OUTPUT_EXE)

# Test bundled executable with data files
windows-test: $(PYINSTALLER_OUTPUT_EXE)
	uv run pytest -x -s -v tests\pyhelloworld\test_pyhelloworld.py

windows-installer: windows-build
	@if defined MAKENSIS_PATH (
		setlocal enableDelayedExpansion
		powershell.exe -ExecutionPolicy Bypass -Command "$env:MAKENSIS_PATH='!MAKENSIS_PATH!'; .\build.ps1 windows-installer"
	) else (
		powershell.exe -ExecutionPolicy Bypass -File build.ps1 windows-installer
	)

 windows-test-install: windows-installer
	@powershell.exe -ExecutionPolicy Bypass -Command "cmd /c \"set INSTALL_DIR=%TEMP%\\pyhelloworld && powershell.exe -ExecutionPolicy Bypass -File build.ps1 windows-install && set INSTALL_DIR=%TEMP%\\pyhelloworld && powershell.exe -ExecutionPolicy Bypass -Command '& ''%TEMP%\\pyhelloworld\\pyhelloworld.exe' --data-path data.txt 2>&1' && cmd /c \"if errorlevel 0 (echo [v] Unit test passed: Output matches 'Hello world') else (echo [x] Unit test failed)\" && cmd /c \"rmdir /s /q %TEMP%\\pyhelloworld\""

