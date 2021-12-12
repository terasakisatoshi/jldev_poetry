def greet(msg: str = "World"):
    return f"Hello {msg}"


def loop(n: int):
    s = 0
    for i in range(n + 1):
        s += i
    return s
