#!/bin/bash
source config

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOCKERFILE="$REPO_ROOT/docker/Dockerfile"

mkdir -p "$REPO_ROOT/cpp/input" "$REPO_ROOT/cpp/run_time_config"

# DOCKER_IMG_PREFIX
DOCKER_TARGET="dev-env"
DOCKER_FULL_IMG_NAME="${DOCKER_IMG_PREFIX}${DOCKER_TARGET}"



# BUILD #
clear
docker build -f "$DOCKERFILE" --target "$DOCKER_TARGET" -t "$DOCKER_FULL_IMG_NAME" "$REPO_ROOT"
docker image prune -f

# RUN #
clear; clear_dir "$DIR_LOG"
docker run --rm -it \
  -v "$REPO_ROOT/cpp:/workspace" \
  -w /workspace \
  "$DOCKER_FULL_IMG_NAME" \
  bash "./docker/start.sh" "$@"

compilation_status=$?
docker container prune -f
clear

cat $LOG_start && echo -e "\n"
if [ $compilation_status -eq 0 ]; then
  echo "✅ SUCCESS"
else
  echo "❌ FAILED"
fi
