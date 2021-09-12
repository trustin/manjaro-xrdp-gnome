#!/usr/bin/env bash
set -Eeuo pipefail
if [[ -z "$DISPLAY" ]]; then
  echo "Missing DISPLAY environment variable"
  exit 1
fi

if [[ ! "$DISPLAY" =~ (^:([0-9]+)(\.[0-9]+)?$) ]]; then
  echo "Unexpected DISPLAY environment variable value: $DISPLAY"
  exit 1
fi

DISPLAY_NO="${BASH_REMATCH[2]}"
XORGXRDP_LOG="$HOME/.xorgxrdp.$DISPLAY_NO.log"
if [[ ! -a "$XORGXRDP_LOG" ]]; then
  echo "Missing xorgxrdp log: $XORGXRDP_LOG"
  exit 1
fi

if ! grep -qF 'rdpClientConProcessMsgClientInfo: got RFX capture' "$XORGXRDP_LOG"; then
  zenity --warning --no-wrap --text='RemoteFX is not enabled.
Please enable it for lower bandwidth overhead.
See: <a href=\"https://github.com/neutrinolabs/xrdp/issues/1026\">https://github.com/neutrinolabs/xrdp/issues/1026</a>'
fi
