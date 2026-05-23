#!/bin/bash
# Kompilacja rozszerzenia C++ (pybind11), potem obraz Dockera Pythona i uruchomienie skryptu.
set -eo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== [1/3] C++ (Docker: -p = jeden moduł .so: całe _src + pybind w _py) ==="
( cd "$ROOT/cpp" && ./docker/compile.sh -p )

echo ""
echo "=== [2/3] Obraz Pythona ==="
( cd "$ROOT/python" && ./docker/compile.sh )

echo ""
echo "=== [3/3] Uruchomienie Pythona (montuje cpp/build) ==="
( cd "$ROOT/python" && ./docker/run.sh "$@" )
