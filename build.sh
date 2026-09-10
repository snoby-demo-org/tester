#!/usr/bin/env bash
# Build the node image from the LOCAL source tree (./src).
set -euo pipefail

SRC_DIR="${SRC_DIR:-src}"
DOCKERFILE="${DOCKERFILE:-Dockerfile}"

if git -C "${SRC_DIR}" rev-parse --short HEAD >/dev/null 2>&1; then
  LOCAL_SHA="$(git -C "${SRC_DIR}" rev-parse --short HEAD)"
else
  LOCAL_SHA="local"
fi

TAG="${TAG:-${LOCAL_SHA}}"
NO_CACHE="${NO_CACHE:-0}"

echo "Building iotapi322/crypto-node:${TAG} from ${SRC_DIR}/ (@ ${LOCAL_SHA})"

docker_args=(-f "${DOCKERFILE}" -t "iotapi322/crypto-node:${TAG}" .)
if [[ "${NO_CACHE}" == "1" ]]; then
  docker_args=(--no-cache "${docker_args[@]}")
fi
docker build "${docker_args[@]}"
