#!/usr/bin/env bash
set -Eeuo pipefail

docker stop manjaro-xrdp-gnome >/dev/null 2>&1 || true
docker rm manjaro-xrdp-gnome >/dev/null 2>&1 || true
docker create --name manjaro-xrdp-gnome \
  --privileged \
  --env "PUID=$(id -u)" \
  --env "PUSER=$(id -un)" \
  --publish 23389:3389 \
  --publish 2222:22 \
  --shm-size 1G \
  ghcr.io/trustin/manjaro-xrdp-gnome:latest
docker start manjaro-xrdp-gnome
