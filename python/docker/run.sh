#!/bin/bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$PYTHON_ROOT/.." && pwd)"
CPP_BUILD="$REPO_ROOT/cpp/build"

cd "$PYTHON_ROOT"

source config

DOCKER_TARGET="python-runner"
DOCKER_FULL_IMG_NAME="${DOCKER_IMG_PREFIX}${DOCKER_TARGET}"

if [ ! -d "$CPP_BUILD" ]; then
  echo "❌ Brak katalogu $CPP_BUILD — najpierw zbuduj C++ (np. ./start.sh z katalogu PythonCppBinding lub: cd cpp && ./docker/compile.sh -p)."
  exit 1
fi

clear_dir "$DIR_LOG"
mkdir -p "$(dirname "$LOG_run")"

clear
docker run --rm -it \
  -v "$PYTHON_ROOT:/workspace" \
  -v "$CPP_BUILD:/cpp_build:ro" \
  -w /workspace \
  -e PYTHONPATH=/cpp_build \
  -e LD_LIBRARY_PATH=/cpp_build \
  "$DOCKER_FULL_IMG_NAME" \
  python3 app/main.py "$@" 2>&1 > "$LOG_run"

run_status="${PIPESTATUS[0]}"
docker container prune -f
clear

cat "$LOG_run" && echo -e "\n"
if [ "$run_status" -eq 0 ]; then
  echo "✅ SUCCESS"
else
  echo "❌ FAILED"
fi
exit "$run_status"
