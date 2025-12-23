# Variables
BASE_NAME = pyhelloworld
SPEC_FILE = $(BASE_NAME).spec
SRCS = src/$(BASE_NAME)/$(BASE_NAME).py
DATA_FILES = data/*
CONFIG_FILES = pyproject.toml
COMPILED_EXE = dist/$(BASE_NAME).exe
INSTALLER_EXE = dist/$(BASE_NAME)-installer.exe
SPACE = $(empty) $(empty)
empty =

# NSIS installer path (optional, set if makensis.exe is not in PATH)
MAKENSIS_PATH ?=

# Suppress command echoing for cleaner output
.SILENT:

.PHONY: help sync sync-all test run lint format typecheck clean build-scripts windows-compile windows-build-installer-admin windows-build-installer-test windows-test-installed


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
	@echo "  windows-compile  Build a Windows executable with PyInstaller"
	@echo "  windows-test-compiled  Test if compiled exe is runnable"
	@echo "  windows-build-installer-admin  Create Windows installer (admin-level, HKLM registry)"
	@echo "  windows-build-installer-test  Create test installer (user-level, no UAC, HKCU registry)"
	@echo "  windows-run-installer-test  Install test installer silently to TEMP directory"
	@echo "  windows-test-installed  Install test installer silently to TEMP directory"

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

build-scripts:
	uv build

# Windows build targets implemented directly in Makefile
windows-compile: $(COMPILED_EXE)

 $(COMPILED_EXE): $(SRCS) $(DATA_FILES) $(CONFIG_FILES)
	@echo Building $(COMPILED_EXE) - dependencies changed
	uv run pyinstaller "$(SPEC_FILE)" --clean
	@powershell.exe -Command "if (!(Test-Path '$(COMPILED_EXE)')) { Write-Host 'Error: Build failed - executable not found at $(COMPILED_EXE)'; exit 1 }"
	@echo Build completed successfully: $(COMPILED_EXE)

# Test bundled executable with data files
windows-test-compiled: $(COMPILED_EXE)
	uv run pytest -x -s -v tests/test_compiled.py

windows-build-installer-admin: $(COMPILED_EXE) build-scripts
	uv run build-installer

$(INSTALLER_EXE): $(COMPILED_EXE)
	make windows-build-installer-admin

windows-build-installer-test: $(COMPILED_EXE) build-scripts
	uv run build-installer --test

windows-run-installer-test: windows-build-installer-test build-scripts
	uv run windows-test-install

windows-test-installed: windows-build-installer-test
	uv run pytest -x -s -v tests/test_installed.py
