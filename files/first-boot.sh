#!/usr/bin/env bash
set -Eeuo pipefail

self_destruct() {
  rm -f '/first-boot.sh'
  systemctl disable first-boot.service
}

trap self_destruct EXIT

{
set -x

# Generate the RSA key for XRDP.
rm -f /etc/xrdp/rsakeys.ini
xrdp-keygen xrdp /etc/xrdp/rsakeys.ini

# Create a user.
export PHOME="/home/$PUSER"
useradd -u "$PUID" -g users -d "$PHOME" -m -N "$PUSER"
gpasswd -a "$PUSER" docker
gpasswd -a "$PUSER" wheel
gpasswd -a "$PUSER" wireshark

# Set user's password.
if [[ -z "$PASSWORD" ]]; then
  # Use the username as the password if not given.
  PASSWORD="$PUSER"
fi
echo -e "$PASSWORD\n$PASSWORD" | passwd "$PUSER"

# Switch to zsh.
chsh -s /bin/zsh "$PUSER"

# Allow first-login.sh to log to /var/log
touch /var/log/first-login.log
chown "$PUSER:users" /var/log/first-login.log

echo 'first-boot.sh finished successfully.'

} >/var/log/first-boot.log 2>&1
