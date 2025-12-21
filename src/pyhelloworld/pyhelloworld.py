import argparse
import sys
from pathlib import Path


def health() -> str:
    """Return health check status."""
    return "ok"

def main(args: argparse.Namespace) -> None:
    """Print greeting message.

    Args:
        data: If True, print additional data information.
    """
    data_path = Path(args.data_path)
    data_value = data_path.read_text().strip()
    print(f"Hello {data_value}")


def cli() -> None:
    """Command line interface."""
    parser = argparse.ArgumentParser(description="Hello World Application")
    parser.add_argument("--data-path", type=str, required=True, help="path to the data.txt")
    args = parser.parse_args(sys.argv[1:])
    main(args)


if __name__ == "__main__":
    cli()
