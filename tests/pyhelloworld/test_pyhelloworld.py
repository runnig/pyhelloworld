from typing import Any

from pyhelloworld import health, main


def test_main(capsys: Any) -> None:
    """Test that main function prints the expected output."""
    main()
    captured = capsys.readouterr()
    assert captured.out == "Hello from pyhelloworld!\n"


def test_health() -> None:
    """Test health function returns expected status."""
    assert "ok" == health()
