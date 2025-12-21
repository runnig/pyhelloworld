"""
Updated pyhelloworld module with improved path resolution for PyInstaller bundles.
"""

import argparse
import sys

# Import paths module directly
try:
    from .paths import get_data_path, is_bundled
except ImportError:
    # Handle relative import for PyInstaller
    from pyhelloworld.paths import get_data_path, is_bundled


def health() -> str:
    """Return health check status."""
    return "ok"


def main(args: argparse.Namespace) -> None:
    """Print greeting message.

    Args:
        data: If True, print additional data information.
    """
    # Use the improved path resolution
    data_path = get_data_path('data.txt')
    
    # Check if data file exists
    if not data_path.exists():
        print(f"Error: Data file not found at {data_path}")
        if is_bundled():
            print("This appears to be a bundled application.")
            print("Please ensure the data file is properly bundled in the spec file.")
        sys.exit(1)
    
    data_value = data_path.read_text().strip()
    print(f"Hello {data_value}")
    
    if is_bundled():
        print("(Running from bundled application)")
    else:
        print("(Running from development environment)")


def cli() -> None:
    """Command line interface."""
    parser = argparse.ArgumentParser(description="Hello World Application")
    parser.add_argument(
        "--data-path", 
        type=str, 
        default="data.txt",
        help="path to the data.txt (default: data.txt, bundled automatically)"
    )
    # Add version argument for better CLI experience
    parser.add_argument(
        "--version", 
        action="version", 
        version="%(prog)s 0.1.0"
    )
    
    args = parser.parse_args(sys.argv[1:])
    main(args)


if __name__ == "__main__":
    cli()