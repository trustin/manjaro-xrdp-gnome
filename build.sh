#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")"
if [[ -a .buildrc ]]; then
  . .buildrc
fi

if [[ -n "${MIRROR_URL:-}" ]]; then
  echo "Using mirror: $MIRROR_URL"
  exec docker build --tag 'ghcr.io/trustin/manjaro-xrdp-gnome:latest' --build-arg "MIRROR_URL=$MIRROR_URL" "$@" .
else
  exec docker build --tag 'ghcr.io/trustin/manjaro-xrdp-gnome:latest' "$@" .
fi
