# Overview

* Source code lives in the src/ directory.
* Tests are located in the tests/ directory.
* Build configuration is defined in pyproject.toml.
* Development utilities (linting, formatting) are available via the Makefile.
* IMPORTANT: source .venv/bin/activate activates the virtual environment
* IMPORTANT: check the virtual environment has been activated:
  "echo $VIRTUAL_ENV"
* Run "make sync" to install dependencies
* Run "make sync all" to install all dependencies, including development (pytest, ruff)
* Run all tests: "make test"
* Invoke the pytest directly for a concrete test file:
  "uv run pytest -x -n 1 -v -s tests/path/to/test_mycode.py"
* Run pre‑commit hooks (lint, type checking, etc.): "make lint"
* Auto‑format code with ruff: "make format"
