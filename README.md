# Python ↔ C++ (pybind11)

## Idea

1. **C++** buduje natywny moduł Pythona (`python_cpp_binding`) przez **pybind11** (plik `.so` ląduje w `cpp/build/`).
2. **Python** działa w osobnym obrazie Dockera; przy starcie montuje `cpp/build` jako `/cpp_build` i ustawia `PYTHONPATH=/cpp_build`, żeby `import python_cpp_binding` działał bez kopiowania plików.

Ważne: moduł `.so` musi być zbudowany w środowisku **zgodnym** z tym, w którym go ładujesz (stąd ten sam Ubuntu 22.04 w obu Dockerfile’ach i budowanie modułu w kontenerze C++).

## Szybki start (wszystko naraz)

Z katalogu repozytorium:

```bash
chmod +x build_all.sh cpp/docker/*.sh cpp/scripts/*.sh python/docker/*.sh
./build_all.sh
```

## Krok po kroku

- Tylko C++ (moduł dla Pythona):

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
| Włączenie budowy modułu w CMake | `BUILD_PYTHON_MODULE` (włączane przez `./docker/compile.sh -p`) |

## Alternatywy (na później)

- **ctypes / C ABI**: eksport `extern "C"` z biblioteki `.so`, bez pybind11 — mniej wygodne typy.
- **setuptools + scikit-build-core**: pakiet pip z natywnym modułem — wygodne przy publikacji, większy narzut konfiguracji.
