#!/usr/bin/env bash
set -Eeuo pipefail

self_destruct() {
  rm -f "$HOME/.config/autostart/first-login.desktop"
}

trap self_destruct EXIT

{

dconf load / <<EOF

[org/gnome/desktop/calendar]
show-weekdate=true

[org/gnome/desktop/input-sources]
xkb-options=['caps:super', 'terminate:ctrl_alt_bksp', 'lv3:ralt_switch']

[org/gnome/desktop/interface]
clock-show-seconds=true
clock-show-weekday=true
cursor-size=21
cursor-theme='xcursor-breeze'
document-font-name='Sans 11'
enable-animations=false
font-antialiasing='grayscale'
font-hinting='none'
font-name='Sans 11'
gtk-theme='Matcha-sea'
monospace-font-name='Monospace 11'

[org/gnome/desktop/wm/preferences]
titlebar-font='Sans Bold 11'

[org/gnome/gnome-system-monitor]
network-total-in-bits=false
show-whose-processes='all'

[org/gnome/settings-daemon/plugins/color]
night-light-enabled=false

[org/gnome/settings-daemon/plugins/xsettings]
antialiasing='grayscale'
hinting='none'

[org/gnome/shell/extensions/dash-to-dock]
animate-show-apps=false
click-action='minimize-or-previews'
custom-theme-shrink=true
dash-max-icon-size=32
dock-fixed=true
dock-position='LEFT'
show-apps-at-top=true
show-mounts=false
EOF

echo 'first-login.sh finished successfully.'

} > /var/log/first-login.log 2>&1
