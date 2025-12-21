import argparse
from pathlib import Path
from typing import Any

from pyhelloworld import health, main


def test_main(capsys: Any) -> None:
    """Test that main function prints the expected output with data path."""
    data_path = Path(__file__).parent.parent.parent / "data" / "data.txt"
    args = argparse.Namespace(data_path=str(data_path))
    main(args)
    captured = capsys.readouterr()
    assert captured.out == "Hello world\n"


def test_health() -> None:
    """Test health function returns expected status."""
    assert "ok" == health()
