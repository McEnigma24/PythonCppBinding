"""Przykład: Matrix z C++ ↔ numpy (buffer protocol — np.asarray bez kopii danych)."""

import sys

import numpy as np

import python_cpp_binding as native


def main() -> None:
    print("cpp_add(40, 2):", native.add(40, 2))
    print("cpp_sub(40, 2):", native.sub(40, 2))

    m = native.Matrix(2, 3, 1.0)
    print("Matrix(2, 3, 1.0) shape:", m.shape)
    view = np.asarray(m)
    print("np.asarray(m) (widok tej samej pamięci):\n", view)
    m[0, 0] = 42.0
    print("po m[0,0]=42, widok numpy:\n", view)
    print("matrix_sum(m):", native.matrix_sum(m))

    from_np = native.Matrix(np.array([[1.0, 2.0], [3.0, 4.0]], dtype=np.float64))
    print("Matrix z numpy [[1,2],[3,4]] suma:", native.matrix_sum(from_np))


if __name__ == "__main__":
    main()
