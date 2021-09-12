#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")"

./build.sh "$@"
docker push ghcr.io/trustin/manjaro-xrdp-gnome:latest
