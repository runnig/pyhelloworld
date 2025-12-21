.PHONY: help sync sync-all test run lint format clean build windows-build windows-installer windows-all


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
	@echo "  windows-build  Build Windows executable with PyInstaller"
	@echo "  windows-installer  Create Windows installer"
	@echo "  windows-all    Complete Windows build and installer"

# sync the package and dependencies
sync:
	uv sync --active

# sync development dependencies
sync-all:
	uv sync --all-groups --active

# Run tests
test:
	uv run pytest tests/ -v --active

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
	@if exist build rmdir /s /q build
	@if exist dist rmdir /s /q dist
	@if exist *.egg-info rmdir /s /q *.egg-info
	@powershell -Command "Get-ChildItem -Path . -Recurse -Directory -Name '__pycache__' | ForEach-Object { Remove-Item -Path $_ -Recurse -Force -ErrorAction SilentlyContinue }"
	@del /s /q *.pyc 2>nul

# Clean PyInstaller artifacts only
clean-pyinstaller:
	@if exist build rmdir /s /q build
	@if exist dist rmdir /s /q dist
	@del *.spec 2>nul

# Build the package
build: clean
	uv build

# Windows build targets (use PowerShell script on Windows)
windows-build:
	@set PYTHONPATH=%CD%;%CD%\src
	@set PATH=%PATH%;g:\nsis
	@powershell.exe -ExecutionPolicy Bypass -File build.ps1 windows-build

windows-test: windows-build
	@powershell.exe -ExecutionPolicy Bypass -File build.ps1 windows-test

windows-installer: windows-build
	@powershell.exe -ExecutionPolicy Bypass -File build.ps1 windows-installer

windows-all:
	@powershell.exe -ExecutionPolicy Bypass -File build.ps1 windows-all
