#!/bin/bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PYTHON_ROOT"

source config

DOCKER_TARGET="python-runner"
DOCKER_FULL_IMG_NAME="${DOCKER_IMG_PREFIX}${DOCKER_TARGET}"

clear
docker build -f docker/Dockerfile -t "$DOCKER_FULL_IMG_NAME" .
docker image prune -f
clear
echo "✅ Obraz Pythona zbudowany: $DOCKER_FULL_IMG_NAME"
