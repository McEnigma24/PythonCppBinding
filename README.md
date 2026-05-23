# Python ↔ C++ (pybind11)

Projekt **PythonCppBinding**: C++ (`cpp/`) z modułem **pybind11**, osobny runtime **Python** (`python/`), wspólne obrazy **Docker** (`docker/`).

## Idea

1. **C++ z `-p`**: jeden artefakt **dla Pythona** — plik **`python_cpp_binding.cpython-…-linux-gnu.so`** w `cpp/build/`. W środku jest skompilowane całe **`_src`** (w tym `main.cpp`, ale **bez** `main()` — target modułu **nie** definiuje `BUILD_EXECUTABLE`) oraz **`_py/binding.cpp`**. Zależności typu **core** są linkowane w tym samym obrazie binarnym modułu (np. statyczna `libcore.a`); biblioteki systemowe (np. **OpenMP** / `libgomp`) biorą się z obrazu Dockera. Oprócz tego CMake domyślnie buduje też **`TEMPLATE.exe`** — osobny target; do Pythona wystarcza moduł `.so` w `cpp/build/`.
2. **Python**: kontener **`python-runner`** montuje **`cpp/build`** jako **`/cpp_build`**, ustawia **`PYTHONPATH`** i **`LD_LIBRARY_PATH`**, żeby **`import python_cpp_binding`** i ewentualne zależności dynamiczne działały bez kopiowania plików do obrazu Pythona.

**Spójność ABI:** moduł buduj w tym samym typie środowiska, w którym go uruchamiasz (stąd **Ubuntu 22.04** we wspólnej bazie Dockera).

### Skąd `import python_cpp_binding` wie, który plik otworzyć?

Nazwa modułu to **`python_cpp_binding`**. Loader szuka pliku wg PEP 3149 (np. **`python_cpp_binding.cpython-310-x86_64-linux-gnu.so`**) w **`sys.path`**, m.in. po **`PYTHONPATH=/cpp_build`**. Długi suffix jest **normalny** — w kodzie zawsze **`import python_cpp_binding`**. Wywołania typu **`native.add(...)`** idą do C++ zarejestrowanego w **`_py/binding.cpp`** (`PYBIND11_MODULE` / `m.def`).

---

## Struktura

| Ścieżka | Rola |
|---------|------|
| `docker/Dockerfile` | Jeden multi-stage Dockerfile: **`runtime-base`** → **`dev-env`** / **`runner`** / **`python-runner`** (szczegóły: [`docker/README.md`](docker/README.md)) |
| `cpp/` | CMake, `_src/`, `_inc/`, `_py/binding.cpp`, `docker/compile.sh`, `docker/start.sh`, … |
| `python/` | `app/main.py`, `docker/compile.sh`, `docker/run.sh` |
| `start.sh` | Jednym poleceniem: C++ **`-p`** → obraz Pythona → `python3 app/main.py` |

---

## Szybki start

Z katalogu **`PythonCppBinding`**:

```bash
chmod +x start.sh cpp/docker/*.sh cpp/scripts/*.sh python/docker/*.sh
./start.sh
```

Opcjonalnie (powłoka interaktywna w **`dev-env`** z tym samym montowaniem co przy kompilacji):

```bash
chmod +x cpp/docker/enter_dev_container.sh
cd cpp && ./docker/enter_dev_container.sh
```

---

## Krok po kroku

### Cały pipeline (root)

```bash
./start.sh [argumenty przekazywane do python/app/main.py]
```

### Tylko C++ w Dockerze (`dev-env`)

Z katalogu **`cpp`**:

```bash
./docker/compile.sh          # samo exe (+ opcjonalnie inne flagi)
./docker/compile.sh -p       # + moduł pybind11 (jeden .so z `_src` + binding)
./docker/compile.sh -c       # czyści `build/` przed kolejnymi opcjami (getopts)
```

Log z **`production.sh`** jest zapisywany w **`cpp/log/start.log`** (`tee` w kontenerze) i na końcu **`compile.sh`** wypisuje go ponownie wraz z **SUCCESS** / **FAILED**.

### Flagi przekazywane do `docker/start.sh` (getopts)

| Flaga | Znaczenie |
|-------|-----------|
| `-c` | Czyści katalog **`build/`** |
| `-t` | Tryb testów CMake (**`CTEST_ACTIVE`**) |
| `-l` | Budowa biblioteki zamiast exe (**`BUILD_LIBRARY`**) — zgodnie z `CMakeLists.txt` |
| `-p` | Moduł Pythona (**`BUILD_PYTHON_MODULE`**) |

Uwaga: w **`docker/start.sh`** opcje **`-t`**, **`-l`** i **`-p`** kończą pętlę **`getopts`** przez **`break`** — w **jednym** wywołaniu zadziała tylko **pierwsza** z nich w kolejności skanowania (np. `-lp` ustawi tylko **`-l`**). Łączenie flag: osobne wywołania albo zmiana skryptu (usunięcie `break`).

### Obraz Pythona

```bash
cd python && ./docker/compile.sh
```

### Uruchomienie aplikacji Python (wymaga `cpp/build/` z modułem po **`compile.sh -p`**)

```bash
cd python && ./docker/run.sh
```

---

## Gdzie dopinać własny kod

| Cel | Plik |
|-----|------|
| API widoczne w Pythonie | `cpp/_py/binding.cpp` (`PYBIND11_MODULE`, `m.def`, …) |
| Logika C++ (także generowana) | `cpp/_src/`, `cpp/_inc/` — wywołania z `binding.cpp` |

### Przykład: obiekt `Matrix` ↔ NumPy

Klasa **`Matrix`** (`cpp/_inc/matrix.hpp`) jest zarejestrowana w `binding.cpp` z **`py::buffer_protocol()`**, więc:

- **`np.asarray(matrix)`** daje **widok** tej samej pamięci co obiekt C++ (bez kopii bufora).
- **`native.Matrix(numpy_array_2d)`** buduje kopię z `ndarray` `float64` o **`ndim == 2`**.
- Funkcje C++ mogą przyjmować **`const Matrix&`** (np. `matrix_sum`) — z Pythona przekazujesz ten sam typ obiektu.
| CMake (exe / testy / moduł) | `cpp/CMakeLists.txt`, opcje **`BUILD_PYTHON_MODULE`**, **`BUILD_LIBRARY`**, **`CTEST_ACTIVE`** |

---

## Alternatywy (na później)

- **ctypes / C ABI** — bez pybind11, więcej ręcznej roboty przy typach.
- **setuptools / scikit-build-core** — pakiet pip z rozszerzeniem, wygodniejsze przy publikacji.
