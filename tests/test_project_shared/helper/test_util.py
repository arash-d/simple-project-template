from project_shared.helper.util import greet


def test_greet():
    assert greet("foo") == "Hello, foo"
