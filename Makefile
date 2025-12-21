.PHONY: help sync sync-all test run lint format clean build


# Default target
help:
	@echo "Available commands:"
	@echo "  sync     sync the package"
	@echo "  sync-all sync development dependencies"
	@echo "  test        Run tests"
	@echo "  run         Run the main script"
	@echo "  lint        Run linting"
	@echo "  format      Format code"
	@echo "  clean       Clean build artifacts"
	@echo "  build       Build the package"

# sync the package and dependencies
sync:
	uv sync

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
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info/
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete

# Build the package
build: clean
	uv build
