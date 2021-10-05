#!/usr/bin/env bash
set -Eeuo pipefail

self_destruct() {
  rm -f '/first-boot.sh' '/first-boot-local.sh'
  systemctl disable first-boot.service
}

trap self_destruct EXIT

{
set -x

# Generate the RSA key for XRDP.
rm -f /etc/xrdp/rsakeys.ini
xrdp-keygen xrdp /etc/xrdp/rsakeys.ini

# Create a user.
PHOME="/home/$PUSER"
useradd --badname -u "$PUID" -g users -d "$PHOME" -m -N "$PUSER"
gpasswd -a "$PUSER" docker
gpasswd -a "$PUSER" wheel
gpasswd -a "$PUSER" wireshark

# Set user's password.
# Use the username as the password.
echo -e "$PUSER\n$PUSER" | passwd "$PUSER"

# Switch to zsh.
chsh -s /bin/zsh "$PUSER"

# Allow first-login.sh to log to /var/log
touch /var/log/first-login.log
chown "$PUSER:users" /var/log/first-login.log

if [[ -x /first-boot-local.sh ]]; then
  echo 'Running first-boot-local.sh ..'
  export PUSER
  export PUID
  export PHOME
  /first-boot-local.sh
fi

echo 'first-boot.sh finished successfully.'

} >/var/log/first-boot.log 2>&1
