"""
Demo wszystkiego zarejestrowanego w cpp/_py/binding.cpp (kolejność jak w module).
"""

import numpy as np

import python_cpp_binding as native


def main() -> None:
    # --- m.def: add, sub ---
    print("add(40, 2):", native.add(40, 2))
    print("sub(40, 2):", native.sub(40, 2))

    # --- Matrix.__init__(rows, cols) — macierz zer ---
    m0 = native.Matrix(2, 3)
    print("Matrix(2, 3) zeros shape:", m0.shape, "\n", np.asarray(m0))

    # --- Matrix.__init__(rows, cols, fill_value) ---
    m_fill = native.Matrix(2, 3, 5.0)
    print("Matrix(2, 3, 5.0):\n", np.asarray(m_fill))

    # --- Matrix.__init__(array) z numpy 2D float64 ---
    arr = np.array([[1.0, 2.0], [3.0, 4.0]], dtype=np.float64)
    m_np = native.Matrix(arr)
    print("Matrix(numpy 2x2):\n", np.asarray(m_np))

    # --- buffer protocol: np.asarray (widok tej samej pamięci) ---
    view = np.asarray(m_fill)
    print("np.asarray(m_fill) przed zmianą [0,0]:\n", view)
    m_fill[0, 0] = 99.0  # __setitem__
    print("po m_fill[0, 0] = 99 (__setitem__), widok numpy:\n", view)

    # --- shape (read-only) ---
    print("m_np.shape:", m_np.shape)

    # --- __getitem__ ---
    print("m_np[1, 0] (__getitem__):", m_np[1, 0])

    # --- matrix_sum ---
    print("matrix_sum(m_np):", native.matrix_sum(m_np))

    # --- matrix_add oraz __add__ ---
    a = native.Matrix(2, 2, 1.0)
    b = native.Matrix(2, 2, 2.0)
    summed = native.matrix_add(a, b)
    plus = a + b
    print("matrix_add(a, b):\n", np.asarray(summed))
    print("a + b (__add__):\n", np.asarray(plus))
    print("matrix_add == __add__:", np.array_equal(np.asarray(summed), np.asarray(plus)))


if __name__ == "__main__":
    main()
