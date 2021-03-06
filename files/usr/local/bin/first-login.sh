#!/usr/bin/env bash
set -Eeuo pipefail

self_destruct() {
  rm -f "$HOME/.config/autostart/first-login.desktop"
}

trap self_destruct EXIT

{

# Wait a little bit until other apps and extensions finish
# their initialization process to avoid some race conditions.
sleep 3

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

[org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9]
bold-is-bright=true
scrollback-lines=65536
use-system-font=true
use-theme-colors=false

EOF

if [[ -x '/usr/local/bin/first-login-local.sh' ]]; then
  echo 'Running first-login-local.sh ..'
  /usr/local/bin/first-login-local.sh
fi

echo 'first-login.sh finished successfully.'

} > /var/log/first-login.log 2>&1
