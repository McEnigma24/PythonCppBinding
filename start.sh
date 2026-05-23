#!/bin/bash
source config

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
function my_sleep() { sleep 0; }

echo "=== [1/3] C++ (Docker: -p = jeden moduł .so: całe _src + pybind w _py) ==="
( cd "$ROOT/cpp" && ./docker/compile.sh -p )
my_sleep

echo ""
echo "=== [2/3] Obraz Pythona ==="
( cd "$ROOT/python" && ./docker/compile.sh )
my_sleep

echo ""
echo "=== [3/3] Uruchomienie Pythona (montuje cpp/build) ==="
( cd "$ROOT/python" && ./docker/run.sh "$@" )
my_sleep
