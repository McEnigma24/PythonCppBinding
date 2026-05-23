# Obrazy Dockera (`Dockerfile`)

Jeden plik: **`docker/Dockerfile`** w katalogu **PythonCppBinding** (kontekst budowy = ten sam katalog).

| Target | Opis |
|--------|------|
| `runtime-base` | Ubuntu 22.04 + wspólne biblioteki runtime (`ca-certificates`, `libssl3`, `libcurl4`, …) — baza dla **dev-env**, **runner** i **python-runner**. |
| `dev-env` | Narzędzia kompilacji C++ (`cmake`, kompilatory, `python3-dev` pod pybind11). |
| `builder` | Jak `dev-env`, domyślne `CMD` pod `./docker/start.sh` w montowanym `cpp/`. |
| `runner` | Obraz uruchomieniowy z artefaktami z `cpp/build/` (ścieżki `cpp/…` w `COPY`). |
| `python-runner` | Runtime + Python; **bez** duplikacji pakietów z `runtime-base` (np. `libgomp1` jest już w bazie). |

Skrypty **`cpp/docker/compile.sh`**, **`cpp/docker/run.sh`** i **`python/docker/compile.sh`** wołają `docker build -f …/docker/Dockerfile` z kontekstem **repo root** (`PythonCppBinding`).
