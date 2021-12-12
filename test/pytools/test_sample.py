from pytools import sample


def test_greet():
    assert sample.greet() == "Hello World"


def test_loop():
    assert sample.loop(10) == 55
