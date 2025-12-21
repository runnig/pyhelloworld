.PHONY: help install install-all test run lint format clean build


# Default target
help:
	@echo "Available commands:"
	@echo "  install     Install the package"
	@echo "  install-all Install development dependencies"
	@echo "  test        Run tests"
	@echo "  run         Run the main script"
	@echo "  lint        Run linting"
	@echo "  format      Format code"
	@echo "  clean       Clean build artifacts"
	@echo "  build       Build the package"

# Install the package and dependencies
install:
	uv sync

# Install development dependencies
install-all:
	uv sync --all-groups

# Run tests
test:
	uv run pytest testing/ -v

# Run the main script
run:
	uv run python -m pyhelloworld.pyhelloworld

# Lint code
lint:
	uv run ruff check src/ testing/

# Format code
format:
	uv run ruff format src/ testing/

# Clean build artifacts
clean:
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info/
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete

# Build the package
build: clean
	uv build
