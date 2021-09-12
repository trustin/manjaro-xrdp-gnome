#!/usr/bin/env bash
set -Eeuo pipefail

self_destruct() {
  rm -f "$HOME/.config/autostart/first-login.desktop"
}

trap self_destruct EXIT

{

dconf load / <<EOF

[org/gnome/desktop/interface]
cursor-size=21
cursor-theme='xcursor-breeze'
document-font-name='Sans 11'
enable-animations=false
font-antialiasing='grayscale'
font-hinting='none'
font-name='Sans 11'
gtk-theme='Matcha-sea'
monospace-font-name='Monospace 11'

EOF

echo 'first-login.sh finished successfully.'

} > /var/log/first-login.log 2>&1
