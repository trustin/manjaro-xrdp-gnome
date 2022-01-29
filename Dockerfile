FROM manjarolinux/base:latest

ARG MIRROR_URL

ENV LANG=en_US.UTF-8
ENV TZ=America/Los_Angeles
ENV PATH="/usr/bin:${PATH}"
ENV PUSER=user
ENV PUID=1000

# Remove unnecessary files from the base image.
RUN rm -f /.BUILDINFO /.INSTALL /.PKGINFO /.MTREE

# Configure the locale; enable only en_US.UTF-8 and the current locale.
RUN sed -i -e 's~^\([^#]\)~#\1~' '/etc/locale.gen' && \
  echo -e '\nen_US.UTF-8 UTF-8' >> '/etc/locale.gen' && \
  if [[ "${LANG}" != 'en_US.UTF-8' ]]; then \
    echo "${LANG}" >> '/etc/locale.gen'; \
  fi && \
  locale-gen && \
  echo -e "LANG=${LANG}\nLC_ADDRESS=${LANG}\nLC_IDENTIFICATION=${LANG}\nLC_MEASUREMENT=${LANG}\nLC_MONETARY=${LANG}\nLC_NAME=${LANG}\nLC_NUMERIC=${LANG}\nLC_PAPER=${LANG}\nLC_TELEPHONE=${LANG}\nLC_TIME=${LANG}" > '/etc/locale.conf'

# Configure the timezone.
RUN echo "${TZ}" > /etc/timezone && \
  ln -sf "/usr/share/zoneinfo/${TZ}" /etc/localtime

# Populate the mirror list.
RUN pacman-mirrors --country United_States --api --set-branch stable --protocol https && \
  if [[ -n "${MIRROR_URL}" ]]; then \
    mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak && \
    echo "Server = ${MIRROR_URL}/stable/\$repo/\$arch" > /etc/pacman.d/mirrorlist; \
  fi

# Install the keyrings.
RUN pacman-key --init && \
  pacman -Syy --noconfirm --needed archlinux-keyring manjaro-keyring && \
  pacman-key --populate archlinux manjaro

# Install the core packages.
RUN pacman -S --noconfirm --needed \
  diffutils \
  findutils \
  manjaro-release \
  manjaro-system \
  pacman \
  sudo && \
pacman -Scc --noconfirm

# Make sure everything is up-to-date.
RUN sed -i -e 's~^\(\(CheckSpace\|IgnorePkg\|IgnoreGroup\).*\)$~#\1~' /etc/pacman.conf && \
  pacman -Syyu --noconfirm --needed && \
  mv -f /etc/pacman.conf.pacnew /etc/pacman.conf && \
  sed -i -e 's~^\(CheckSpace.*\)$~#\1~' /etc/pacman.conf && \
  pacman -Scc --noconfirm

# Install the common non-GUI packages.
RUN pacman -S --noconfirm --needed \
  autoconf \
  automake \
  aws-cli \
  base-devel \
  bash-completion \
  bind \
  bison \
  bandwhich \
  bat \
  bpf \
  bpftrace \
  clang \
  cmake \
  dash \
  dmidecode \
  docker \
  downgrade \
  dust \
  exa \
  fakeroot \
  fasd \
  fd \
  flex \
  fzf \
  gdb \
  git \
  glances \
  htop \
  httpie \
  iftop \
  inetutils \
  iproute2 \
  iputils \
  jdk11-openjdk \
  jq \
  logrotate \
  lrzip \
  lsof \
  man-db \
  manjaro-aur-support \
  manjaro-base-skel \
  manjaro-browser-settings \
  manjaro-hotfixes \
  manjaro-pipewire \
  manjaro-zsh-config \
  meson \
  mpdecimal \
  net-tools \
  nfs-utils \
  nodejs-lts-fermium \
  openbsd-netcat \
  openresolv \
  openssh \
  p7zip \
  pamac-cli \
  perf \
  pigz \
  pkgconf \
  procps-ng \
  procs \
  protobuf \
  psmisc \
  python \
  python-cchardet \
  python-docker \
  python-matplotlib \
  python-netifaces \
  python-pip \
  python-setuptools \
  python2 \
  python2-setuptools \
  rclone \
  ripgrep \
  rsync \
  sd \
  squashfs-tools \
  strace \
  sysstat \
  systemd-sysvcompat \
  tcpdump \
  thrift \
  tk \
  tmux \
  traceroute \
  trash-cli \
  tree \
  unace \
  unrar \
  unzip \
  vim \
  wget \
  xz \
  zip && \
pacman -Scc --noconfirm

# Copy the pre-built packages.
COPY packages/ /packages/

# Install the pre-built packages.
RUN pacman -U --noconfirm --needed /packages/*/*.tar.* && rm -fr /packages

# Install ncurses5-compat-libs from AUR.
RUN \
  cd /tmp && \
  sudo -u builder gpg --recv-keys C52048C0C0748FEE227D47A2702353E0F7E48EDB && \
  sudo -u builder git clone https://aur.archlinux.org/ncurses5-compat-libs.git && \
  cd ncurses5-compat-libs && \
  sudo -u builder makepkg --noconfirm && \
  pacman -U --noconfirm --needed /tmp/ncurses5-compat-libs/*.pkg.tar* && \
  rm -fr /tmp/ncurses5-compat-libs

# Install python38 and python39 from AUR.
RUN \
  cd /tmp && \
  sudo -u builder gpg --recv-keys B26995E310250568 && \
  sudo -u builder git clone https://aur.archlinux.org/python38.git && \
  sudo -u builder git clone https://aur.archlinux.org/python39.git && \
  cd /tmp/python38 && sudo -u builder makepkg --noconfirm && \
  pacman -U --noconfirm --needed /tmp/python38/*.pkg.tar* && \
  cd /tmp/python39 && sudo -u builder makepkg --noconfirm && \
  pacman -U --noconfirm --needed /tmp/python39/*.pkg.tar*

# Install the fonts.
RUN pacman -S --noconfirm --needed \
  noto-fonts \
  noto-fonts-cjk \
  noto-fonts-emoji \
  ttf-fira-code \
  ttf-fira-mono \
  ttf-fira-sans \
  ttf-hack && \
pacman -Scc --noconfirm

# Install the common GUI packages.
RUN pacman -S --noconfirm --needed \
  dconf-editor \
  evince \
  firefox \
  gnome-keyring \
  gnome-settings-daemon \
  gvfs-google \
  libappindicator-gtk2 \
  libappindicator-gtk3 \
  manjaro-application-utility \
  pamac-gtk \
  poppler-data \
  qgnomeplatform \
  seahorse \
  wireshark-qt \
  wmctrl \
  xapp \
  xdg-desktop-portal \
  xdg-desktop-portal-gtk \
  xdg-user-dirs \
  xdg-user-dirs-gtk \
  xdg-utils \
  xdotool \
  xorg \
  xorg-twm \
  xterm \
  zenity && \
pacman -Scc --noconfirm

# Install the common themes.
RUN pacman -S --noconfirm --needed \
  gnome-themes-extra \
  gnome-wallpapers \
  gtk-engines \
  gtk-engine-murrine \
  illyria-wallpaper \
  matcha-gtk-theme \
  kvantum-manjaro \
  kvantum-theme-matchama \
  papirus-maia-icon-theme \
  xcursor-breeze && \
pacman -Scc --noconfirm

# Install input methods.
RUN pacman -S --noconfirm --needed \
  fcitx5-chinese-addons \
  fcitx5-hangul \
  fcitx5-m17n \
  fcitx5-mozc \
  fcitx5-rime \
  fcitx5-unikey \
  manjaro-asian-input-support-fcitx5 && \
pacman -Scc --noconfirm

# Install xrdp and xorgxrdp from AUR.
# - Remove the generated XRDP RSA key because it will be generated at the first boot.
# - Unlock gnome-keyring automatically for xrdp login.
RUN \
  pacman -S --noconfirm --needed \
    imlib2 tigervnc libxrandr fuse libfdk-aac ffmpeg nasm xorg-server-devel && \
  cd /tmp && \
  sudo -u builder gpg --recv-keys 61ECEABBF2BB40E3A35DF30A9F72CDBC01BF10EB && \
  sudo -u builder git clone https://aur.archlinux.org/xrdp.git && \
  sudo -u builder git clone https://aur.archlinux.org/xorgxrdp.git && \
  cd /tmp/xrdp && sudo -u builder makepkg --noconfirm && \
  pacman -U --noconfirm --needed /tmp/xrdp/*.pkg.tar* && \
  cd /tmp/xorgxrdp && sudo -u builder makepkg --noconfirm && \
  pacman -U --noconfirm --needed /tmp/xorgxrdp/*.pkg.tar* && \
  rm -fr /tmp/xrdp /tmp/xorgxrdp /etc/xrdp/rsakeys.ini && \
  systemctl enable xrdp.service

# Install the workaround for:
# - https://github.com/neutrinolabs/xrdp/issues/1684
# - GNOME Keyring asks for password at login.
RUN \
  cd /tmp && \
  wget 'https://github.com/matt335672/pam_close_systemd_system_dbus/archive/f8e6a9ac7bdbae7a78f09845da4e634b26082a73.zip' && \
  unzip f8e6a9ac7bdbae7a78f09845da4e634b26082a73.zip && \
  cd /tmp/pam_close_systemd_system_dbus-f8e6a9ac7bdbae7a78f09845da4e634b26082a73 && \
  make install && \
  rm -fr /tmp/pam_close_systemd_system_dbus-f8e6a9ac7bdbae7a78f09845da4e634b26082a73

# Configure Pamac.
RUN sed -i -e \
  's~#\(\(RemoveUnrequiredDeps\|SimpleInstall\|EnableAUR\|KeepBuiltPkgs\|CheckAURUpdates\|DownloadUpdates\).*\)~\1~g' \
  /etc/pamac.conf

# Install the desktop environment packages.
RUN pacman -S --noconfirm --needed \
  baobab \
  disable-tracker \
  eog \
  file-roller \
  gedit \
  gedit-plugins \
  gnome-calculator \
  gnome-control-center \
  gnome-layout-switcher \
  gnome-shell-extension-no-overview \
  gnome-system-monitor \
  gnome-terminal \
  gnome-tweaks \
  lighter-gnome \
  manjaro-gnome-assets \
  manjaro-hello \
  nautilus-admin \
  nautilus-empty-file \
  pamac-gnome-integration \
  polkit-gnome \
  terminator \
  xdg-desktop-portal-gnome && \
pacman -Scc --noconfirm

# Remove the cruft.
RUN rm -f /etc/locale.conf.pacnew /etc/locale.gen.pacnew

# Enable/disable the services.
RUN \
  systemctl enable \
    sshd.service && \
  systemctl mask \
    bluetooth.service \
    dm-event.service \
    dm-event.socket \
    geoclue.service \
    initrd-udevadm-cleanup-db.service \
    lvm2-lvmpolld.socket \
    lvm2-monitor.service \
    power-profiles-daemon.service \
    systemd-boot-update.service \
    systemd-firstboot.service \
    systemd-modules-load.service \
    systemd-network-generator.service \
    systemd-networkd.service \
    systemd-networkd.socket \
    systemd-networkd-wait-online.service \
    systemd-remount-fs.service \
    systemd-udev-settle.service \
    systemd-udev-trigger.service \
    systemd-udevd.service \
    systemd-udevd-control.socket \
    systemd-udevd-kernel.socket \
    udisks2.service \
    upower.service \
    usb-gadget.target \
    usbmuxd.service && \
  systemctl mask --global \
    obex.service \
    pipewire.service \
    pipewire.socket \
    pipewire-media-session.service \
    pipewire-pulse.service \
    pipewire-pulse.socket

# Copy the configuration files and scripts.
COPY files/ /

# Enable the first boot time script.
RUN systemctl enable first-boot.service

# Workaround for the colord authentication issue.
# See: https://unix.stackexchange.com/a/581353
RUN systemctl enable fix-colord.service

# Delete the 'builder' user from the base image.
RUN userdel --force --remove builder

# Switch to the default mirrors since we finished downloading packages.
RUN \
  if [[ -n "${MIRROR_URL}" ]]; then \
    mv /etc/pacman.d/mirrorlist.bak /etc/pacman.d/mirrorlist; \
  fi

# Expose SSH and RDP ports.
EXPOSE 22
EXPOSE 3389

STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
