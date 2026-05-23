#!/bin/bash
# Wejście do kontenera dev-env (jak compile.sh: ten sam obraz i montowanie cpp/).
source config

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOCKERFILE="$REPO_ROOT/docker/Dockerfile"

mkdir -p "$REPO_ROOT/cpp/input" "$REPO_ROOT/cpp/run_time_config"

DOCKER_TARGET="dev-env"
DOCKER_FULL_IMG_NAME="${DOCKER_IMG_PREFIX}${DOCKER_TARGET}"

# printf '\n→ Obraz: %s\n→ Dockerfile: %s\n→ Montowanie: %s  →  /workspace\n\n' "$DOCKER_FULL_IMG_NAME" "$DOCKERFILE" "$REPO_ROOT/cpp"

# BUILD #
clear
docker build -f "$DOCKERFILE" --target "$DOCKER_TARGET" -t "$DOCKER_FULL_IMG_NAME" "$REPO_ROOT"
docker image prune -f

# RUN #
clear
docker run --rm -it \
  -v "$REPO_ROOT/cpp:/workspace" \
  -w /workspace \
  "$DOCKER_FULL_IMG_NAME" \
  bash

docker container prune -f
clear
