#!/bin/bash
set -e  # Arrête le script si une commande échoue

echo "=== Début de baseinstall_part1 ==="

### --- Hostname --- ###
sudo hostnamectl set-hostname --static fedora43

### --- Packages de base --- ###
sudo dnf install -y fastfetch fio btop
sudo dnf install -y google-chrome-stable

### --- Dépôt 1Password --- ###
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc

sudo tee /etc/yum.repos.d/1password.repo > /dev/null << 'EOF'
[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc
EOF

sudo dnf install -y 1password

### --- RPM Fusion (Free + Non-Free) --- ###
sudo dnf install -y \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

sudo dnf install -y \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf update -y
sudo dnf upgrade --refresh -y

### --- Codecs HEVC, HEIC, FFmpeg, VLC --- ###
sudo dnf install -y libheif-freeworld ffmpeg-libs --allowerasing
sudo dnf install -y vlc
sudo dnf install -y rpmfusion-free-release-tainted rpmfusion-nonfree-release-tainted
sudo dnf install -y glxinfo

sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
sudo dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
sudo dnf install -y libdvdcss
sudo dnf --repo=rpmfusion-nonfree-tainted install -y "*-firmware"

### --- Dépôt AnyDesk --- ###
sudo tee /etc/yum.repos.d/AnyDesk-Fedora.repo > /dev/null << 'EOF'
[anydesk]
name=AnyDesk Fedora - stable
baseurl=http://rpm.anydesk.com/fedora/$basearch/
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://keys.anydesk.com/repos/RPM-GPG-KEY
EOF

sudo dnf install -y anydesk

### --- Installation de Signal via Flatpak --- ###
sudo dnf install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub org.signal.Signal

### --- Installation de Discord --- ###
sudo dnf install -y discord

### --- Nettoyage --- ###
sudo dnf clean all -y
sudo dnf makecache -y
sudo dnf update -y
sudo dnf upgrade -y

echo "=== Installation terminée avec succès ==="
