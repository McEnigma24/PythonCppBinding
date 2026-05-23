#!/bin/bash
source config

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PYTHON_ROOT"


DOCKER_TARGET="python-runner"
DOCKER_FULL_IMG_NAME="${DOCKER_IMG_PREFIX}${DOCKER_TARGET}"

clear
docker build -f "$REPO_ROOT/docker/Dockerfile" --target "$DOCKER_TARGET" -t "$DOCKER_FULL_IMG_NAME" "$REPO_ROOT"
docker image prune -f
clear
echo "✅ Obraz Pythona zbudowany: $DOCKER_FULL_IMG_NAME"
