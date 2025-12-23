# Variables
BASE_NAME = pyhelloworld
SPEC_FILE = $(BASE_NAME).spec
SRCS = src/$(BASE_NAME)/$(BASE_NAME).py
DATA_FILES = data/*
CONFIG_FILES = pyproject.toml
COMPILED_EXE = dist/$(BASE_NAME).exe
INSTALLER_OUTPUT = dist/$(BASE_NAME)-installer.exe
SPACE = $(empty) $(empty)
empty =

# NSIS installer path (optional, set if makensis.exe is not in PATH)
MAKENSIS_PATH ?=

# Suppress command echoing for cleaner output
.SILENT:

.PHONY: help sync sync-all test run lint format typecheck clean build windows-build windows-installer windows-test-installer windows-test-install windows-dev-test windows-status


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
	@echo "  windows-test-installer  Create test installer (user-level, no UAC)"
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
windows-build: $(COMPILED_EXE)

 $(COMPILED_EXE): $(SRCS) $(DATA_FILES) $(CONFIG_FILES)
	@echo Building $(COMPILED_EXE) - dependencies changed
	uv run pyinstaller "$(SPEC_FILE)" --clean
	@powershell.exe -Command "if (!(Test-Path '$(COMPILED_EXE)')) { Write-Host 'Error: Build failed - executable not found at $(COMPILED_EXE)'; exit 1 }"
	@echo Build completed successfully: $(COMPILED_EXE)

# Test bundled executable with data files
windows-test-compiled: $(COMPILED_EXE)
	uv run pytest -x -s -v tests/test_compiled.py

windows-build-installer: windows-build
	uv run build-installer

windows-test-installer: windows-build
	uv run build-installer.py --test

windows-test-install:
	uv run windows-test-install
