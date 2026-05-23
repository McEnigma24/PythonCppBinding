"""Przykład: import modułu zbudowanego przez CMake + pybind11 (katalog cpp/build na PYTHONPATH)."""

import sys
import python_cpp_binding as native


def main() -> None:
    print("Wynik cpp_add(40, 2):", native.add(40, 2))
    print("Wynik cpp_sub(40, 2):", native.sub(40, 2))


if __name__ == "__main__":
    main()
