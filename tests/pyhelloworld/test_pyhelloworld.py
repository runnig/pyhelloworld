import pyhelloworld


def test_main(capsys):
    """Test that main function prints the expected output."""
    pyhelloworld.main()
    captured = capsys.readouterr()
    assert captured.out == "Hello from pyhelloworld!\n"


def test_health():
    assert "ok" == pyhelloworld.health()
