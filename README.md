# Python ↔ C++ (pybind11)

## Idea

1. **C++** z **`-p`**: jeden artefakt **dla Pythona** — plik **`python_cpp_binding.cpython-…-linux-gnu.so`** w `cpp/build/`. W środku jest skompilowane całe **`_src`** (w tym `main.cpp`, ale **bez** `main()` — target modułu nie definiuje `BUILD_EXECUTABLE`) oraz **`_py/binding.cpp`**. Zależności typu **core** trafiają do tego samego linkowania (np. statyczna `libcore.a` w środku, a np. **OpenMP** z systemu). Domyślnie CMake buduje **też** `TEMPLATE.exe` z tych samych źródeł (osobny target) — to nie jest wymagane do działania Pythona, ale zostaje w `build/` obok modułu.
2. **Python** montuje `cpp/build` i ustawia **`PYTHONPATH=/cpp_build`**, żeby **`import python_cpp_binding`** znalazł ten plik po nazwie modułu (suffix `.cpython-310-…` jest normalny — to nadal moduł **`python_cpp_binding`**).

Ważne: moduł `.so` musi być zbudowany w środowisku **zgodnym** z tym, w którym go ładujesz (stąd ten sam Ubuntu 22.04 w obu Dockerfile’ach i budowanie modułu w kontenerze C++).

### Skąd `import python_cpp_binding` wie, który plik otworzyć?

Nazwa modułu w Pythonie to **`python_cpp_binding`**. Loader szuka pliku spełniającego reguły PEP 3149, np. **`python_cpp_binding.cpython-310-x86_64-linux-gnu.so`** w katalogach z `sys.path` (w tym wpisanych przez **`PYTHONPATH`**). Długi suffix jest **normalny** — to nadal ten sam moduł; w kodzie zawsze piszesz `import python_cpp_binding`. Po załadowaniu wywołujesz np. `native.add(...)` — to wołanie idzie do kodu C++ zarejestrowanego w `_py/binding.cpp` (`PYBIND11_MODULE` / `m.def`).

## Szybki start (wszystko naraz)

Z katalogu repozytorium:

```bash
chmod +x build_all.sh cpp/docker/*.sh cpp/scripts/*.sh python/docker/*.sh
./build_all.sh
```

## Krok po kroku

- Tylko C++ (jeden `.so` dla Pythona — całe `_src` + binding w jednym module):

  ```bash
  cd cpp && ./docker/compile.sh -p
  ```

- Tylko obraz Pythona:

  ```bash
  cd python && ./docker/compile.sh
  ```

- Uruchomienie Pythona (wymaga już zbudowanego `cpp/build` z modułem):

  ```bash
  cd python && ./docker/run.sh
  ```

## Gdzie dopinać własny kod

| Cel | Plik |
|-----|------|
| Funkcje / klasy widoczne w Pythonie | `cpp/_py/binding.cpp` (makro `PYBIND11_MODULE`) |
| Logika C++ (w tym generowana) | np. nowe `.cpp` w `cpp/_src/`, potem `binding.cpp` wywołuje te API |
| Włączenie budowy modułu w CMake | `BUILD_PYTHON_MODULE` (`./docker/compile.sh -p`) — jeden plik `python_cpp_binding*.so` z całym `_src` |

## Alternatywy (na później)

- **ctypes / C ABI**: eksport `extern "C"` z biblioteki `.so`, bez pybind11 — mniej wygodne typy.
- **setuptools + scikit-build-core**: pakiet pip z natywnym modułem — wygodne przy publikacji, większy narzut konfiguracji.
