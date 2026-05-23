"""Przykład: import modułu zbudowanego przez CMake + pybind11 (katalog cpp/build na PYTHONPATH)."""

import sys


def main() -> None:
    try:
        import python_cpp_binding as native
    except ImportError as e:
        print(
            "Nie można zaimportować python_cpp_binding.\n"
            "Upewnij się, że C++ zbudowany jest z -p (BUILD_PYTHON_MODULE=ON) "
            "i że PYTHONPATH wskazuje na katalog z plikiem .so (docker/run.sh robi to automatycznie).",
            file=sys.stderr,
        )
        raise e

    print("Wynik cpp_add(40, 2):", native.add(40, 2))


if __name__ == "__main__":
    main()
