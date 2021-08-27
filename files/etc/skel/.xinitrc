#!/bin/bash
# Workaround for GNOME apps starting slowly
# See: https://bbs.archlinux.org/viewtopic.php?id=224787
dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY
exec startlxqt
