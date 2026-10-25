"""Small numerical and symbolic checks for the supported Python baseline."""

import numpy as np
import pandas as pd  # type: ignore[import-untyped]
from scipy.integrate import quad  # type: ignore[import-untyped]
from scipy.linalg import solve  # type: ignore[import-untyped]
import sympy  # type: ignore[import-untyped]


def test_linear_algebra_and_integration():
    matrix = np.array([[3.0, 1.0], [1.0, 2.0]])
    solution = solve(matrix, np.array([9.0, 8.0]))
    np.testing.assert_allclose(solution, [2.0, 3.0])
    value, error = quad(lambda x: x**2, 0, 1)
    assert abs(value - 1 / 3) < 1e-12
    assert error < 1e-10


def test_dataframe_and_symbolic_math():
    frame = pd.DataFrame({"group": ["a", "a", "b"], "value": [1, 2, 4]})
    assert frame.groupby("group")["value"].sum().to_dict() == {"a": 3, "b": 4}
    x = sympy.symbols("x")
    assert sympy.diff(x**3, x) == 3 * x**2
    assert sympy.integrate(x**2, (x, 0, 1)) == sympy.Rational(1, 3)
