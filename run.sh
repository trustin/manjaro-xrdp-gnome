#!/usr/bin/env bash
set -Eeuo pipefail

docker stop manjaro-xrdp-lxqt || true
docker rm manjaro-xrdp-lxqt || true
docker create --name manjaro-xrdp-lxqt \
  --privileged \
  --env "PUID=$(id -u)" \
  --env "PUSER=$(id -un)" \
  --publish 3389:3389 \
  --publish 2222:22 \
  --shm-size 1G \
  ghcr.io/trustin/manjaro-xrdp-lxqt:latest
docker start manjaro-xrdp-lxqt
