FROM manjarolinux/base:latest as base
FROM scratch AS release
COPY --from=base / /

ARG MIRROR_URL

ENV LANG=en_US.UTF-8
ENV TZ=America/Los_Angeles
ENV PATH="/usr/bin:${PATH}"
ENV PUSER=user
ENV PUID=1000

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
  sudo

# Make sure everything is up-to-date.
RUN sed -i -e 's~^\(\(CheckSpace\|IgnorePkg\|IgnoreGroup\).*\)$~#\1~' /etc/pacman.conf && \
  pacman -Syyu --noconfirm --needed && \
  mv -f /etc/pacman.conf.pacnew /etc/pacman.conf && \
  sed -i -e 's~^\(CheckSpace.*\)$~#\1~' /etc/pacman.conf

# Delete the 'builder' user from the base image.
RUN userdel --force --remove builder

# Install the packages independent from a desktop environment.
RUN pacman -S --noconfirm --needed \
  aws-cli \
  base-devel \
  bash-completion \
  bind-tools \
  bandwhich \
  bat \
  dash \
  docker \
  downgrade \
  dust \
  exa \
  fasd \
  fd \
  fzf \
  git \
  glances \
  haveged \
  htop \
  httpie \
  iftop \
  inetutils \
  iproute2 \
  iputils \
  jdk11-openjdk \
  logrotate \
  man-db \
  manjaro-aur-support \
  manjaro-base-skel \
  manjaro-browser-settings \
  manjaro-hotfixes \
  manjaro-pipewire \
  manjaro-zsh-config \
  net-tools \
  nfs-utils \
  openbsd-netcat \
  openssh \
  p7zip \
  pamac-cli \
  pigz \
  procs \
  python \
  python-docker \
  python-matplotlib \
  python-netifaces \
  python-pip \
  python-setuptools \
  python2 \
  python2-pip \
  python2-setuptools \
  rclone \
  ripgrep \
  rsync \
  sd \
  squashfs-tools \
  sysstat \
  systemd-sysvcompat \
  tcpdump \
  tmux \
  traceroute \
  trash-cli \
  tree \
  unzip \
  vim \
  wget \
  zip

# Install the desktop environment packages.
RUN pacman -S --noconfirm --needed \
  firefox \
  gnome-control-center \
  gnome-keyring \
  gnome-layout-switcher \
  gnome-tweaks \
  libappindicator-gtk2 \
  libappindicator-gtk3 \
  lighter-gnome \
  manjaro-gnome-assets \
  manjaro-hello \
  noto-fonts \
  noto-fonts-cjk \
  noto-fonts-emoji \
  pamac-gtk \
  seahorse \
  ttf-hack \
  xdg-desktop-portal \
  xdg-desktop-portal-gtk \
  xorg

# Install the desktop environment packages (part 2).
RUN pacman -S --noconfirm --needed \
  dconf-editor \
  eog \
  evince \
  file-roller \
  gedit \
  gedit-plugins \
  gnome-calculator \
  gnome-system-monitor \
  gnome-terminal \
  gvfs-google \
  poppler-data \
  wireshark-qt \
  wmctrl \
  xdotool \
  zenity

# Install input methods.
RUN pacman -S --noconfirm --needed \
  ibus-libpinyin \
  ibus-anthy \
  ibus-hangul \
  ibus-unikey \
  ibus-m17n \
  manjaro-asian-input-support-ibus

# Remove the unnecessary packages installed by meta-packages.
#RUN pacman -Runc --noconfirm \
#  kidletime

# Configure Pamac.
RUN sed -i -e \
  's~#\(\(RemoveUnrequiredDeps\|EnableAUR\|KeepBuiltPkgs\|CheckAURUpdates\|DownloadUpdates\).*\)~\1~g' \
  /etc/pamac.conf

# Remove the cruft.
RUN rm -f /etc/locale.conf.pacnew /etc/locale.gen.pacnew
RUN pacman -Scc --noconfirm

# Enable/disable the services.
RUN systemctl enable haveged.service
RUN systemctl enable sshd.service
RUN systemctl disable systemd-modules-load.service

# Copy the configuration files and scripts.
COPY files/ /

# Install the AUR packages.
RUN pacman -U --needed --noconfirm \
  /packages/*.pkg.tar* && \
  rm -fr /packages

# Remove the generated XRDP RSA key because it will be generated at the first boot.
RUN rm -f /etc/xrdp/rsakeys.ini

# Enable/disable the services from the AUR packages.
RUN systemctl enable xrdp.service

# Enable the first boot time script.
RUN systemctl enable first-boot.service

# Switch to the default mirrors since we finished downloading packages.
RUN \
  if [[ -n "${MIRROR_URL}" ]]; then \
    mv /etc/pacman.d/mirrorlist.bak /etc/pacman.d/mirrorlist; \
  fi

# Unlock gnome-keyring automatically for xrdp login.
RUN mv /etc/pam.d/xrdp-sesman.patched /etc/pam.d/xrdp-sesman

# Workaround for https://github.com/neutrinolabs/xrdp/issues/1684
RUN sed -i -e 's~^\(.*pam_systemd_home.*\)$~#\1~' /etc/pam.d/system-auth

# Workaround for the colord authentication issue.
# See: https://unix.stackexchange.com/a/581353
RUN systemctl enable fix-colord.service

# Expose SSH and RDP ports.
EXPOSE 22
EXPOSE 3389

CMD ["/sbin/init"]
