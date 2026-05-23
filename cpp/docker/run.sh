#!/bin/bash
source config

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOCKERFILE="$REPO_ROOT/docker/Dockerfile"

./docker/compile.sh "$@"

# DOCKER_IMG_PREFIX
DOCKER_TARGET="runner"
DOCKER_FULL_IMG_NAME="${DOCKER_IMG_PREFIX}${DOCKER_TARGET}"



# BUILD #
clear
docker build -f "$DOCKERFILE" --target "$DOCKER_TARGET" -t "$DOCKER_FULL_IMG_NAME" "$REPO_ROOT"
docker image prune -f

# RUN #
clear; clear_dir "$DIR_OUTPUT"
mkdir -p "$(dirname "$LOG_run")"
docker run --rm -it \
  "$DOCKER_FULL_IMG_NAME" \
  bash -lc 'exec /app/build/*.exe' 2>&1 > "$LOG_run"

run_status="$?"
docker container prune -f
clear

cat $LOG_run && echo -e "\n"
if [ $run_status -eq 0 ]; then
  echo "✅ SUCCESS"
else
  echo "❌ FAILED"
fi
