# Disable camera
sudo modprobe -r  uvcvideo
echo "blacklist uvcvideo"|sudo tee /etc/modprobe.d/blacklistcamera.conf

# Enable camera
# sudo modprobe   uvcvideo
# sudo rm /etc/modprobe.d/blacklistcamera.conf


# Systemwide touchpad tab to click
gsettings get org.gnome.settings-daemon.peripherals.touchpad tap-to-click > /dev/null 2>&1

if [[ $? -eq 0 ]]; then
    gsettings set org.gnome.settings-daemon.peripherals.touchpad tap-to-click true
else
    gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
fi

cat <<EOF | run-as-root tee /etc/X11/xorg.conf.d/00-enable-taps.conf > /dev/null 2>&1
Section "InputClass"
       Identifier "tap-by-default"
       MatchIsTouchpad "on"
       Option "TapButton1" "1"
EndSection
EOF


# Improve font rendering
dnf -y install fedy-font-config
gsettings set org.gnome.settings-daemon.plugins.xsettings antialiasing "rgba"
gsettings set org.gnome.settings-daemon.plugins.xsettings hinting "slight"



# Rpm Fushion
dnf install --nogpgcheck http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-25.noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-25.noarch.rpm -y

# update
dnf clean all
dnf update -y

# Important Stuff
dnf install fribidi harfbuzz cmake curl wget ffmpeg youtube-dl pulseaudio libreoffice-langpack-ar fpaste rsync patch xterm  git yumex-dnf @c-development @development-tools @hardware-support gvfs-mtp simple-mtpfs pavucontrol -y

# Fedy
curl https://www.folkswithhats.org/installer | sudo bash

# Arfedy
dnf clean all && sudo dnf copr enable youssefmsourani/arfedy -y
dnf install arfedy -y


# Gnome addons
dnf install bicon dconf-editor gconf-editor nm-connection-editor -y
dnf install gnome-terminal-nautilus nautilus-search-tool gnome-tweak-tool -y

# Permissive SELinux
sed -i s/^SELINUX=.*$/SELINUX=enforcing/g /etc/selinux/config

# Spotyfiy
dnf config-manager --add-repo=http://negativo17.org/repos/fedora-spotify.repo
dnf -y install spotify-client

# Compression
dnf install zip p7zip gzip cpio unar p7zip-plugins -y

# Power saving
dnf install lm_sensors -y
dnf install hddtemp -y
dnf install powertop -y
systemctl enable powertop

# Torrent
install qbittorrent -y

# Synapse
dnf install synapse -y

# Chrome
rpm --import https://dl-ssl.google.com/linux/linux_signing_key.pub
dnf -y install https://dl.google.com/linux/direct/google-chrome-stable_current_$(uname -i).rpm

	# Fix for double icon in dock
	file="/usr/share/applications/google-chrome.desktop"
	if [ -f ${file} ]; then
	    list=("Desktop Entry" "NewWindow" "NewPrivateWindow")
	    startupWMClass="StartupWMClass=Google-chrome-stable"

	    echo
	    for i in "${list[@]}"; do
		pattern='^\[.*'"$i"'.*\]$'
		section=$(grep "$pattern" $file)
		lineNumber=$(grep -n "$pattern" $file | cut -d : -f 1)

		if [[ $lineNumber ]]; then
		    echo "OK: Section [$i] found."
		    sed --in-place "$lineNumber a $startupWMClass" $file
		else
		    echo "ERROR: Section [$i] not found."
		    exit 1
		fi
	    done
	else
	    echo "Desktop file not found."
	    exit 1
	fi



# Media Playrs
dnf install vlc
dnf install mpv vdr-mpv

# Arabic fonts
dnf install @arabic-support -y

# Media player
dnf install vlc -y
dnf install mpv vdr-mpv -y

# codecs
dnf install -y gstreamer{1,}-{plugin-crystalhd,ffmpeg,plugins-{good,ugly,bad{,-free,-nonfree,-freeworld,-extras}{,-extras}}} libmpg123 lame-libs gstreamer1-libav gstreamer-plugins-espeak xine-lib xine-lib-devel xine-lib-extras gstreamer-plugins-fc gstreamer-rtsp lame gstreamer-ffmpeg ffmpeg x264 faad2 flac amrnb amrwb gstreamer1-plugins-bad-free-gtk --setopt=strict=0 -y

dnf config-manager --set-enabled fedora-cisco-openh264 -y

dnf install mozilla-openh264 gstreamer1-plugin-openh264 -y


# Vim
dnf install vim -y
dnf install nano -y

# Atom
dnf copr -y enable mosquito/atom
dnf -y install atom

# SimpleNote

CACHEDIR="/var/cache/fedy/simplenote";
mkdir -p "$CACHEDIR"
cd "$CACHEDIR"

URL="https://github.com/Automattic/simplenote-electron/$(wget https://github.com/Automattic/simplenote-electron/releases -O - | grep -Po releases/download/v[0-9.]{5}/Simplenote-linux-x64.[0-9.]{5}.tar.gz | head -n 1)"
FILE=${URL##*/}

wget -c "$URL" -O "$FILE"

if [[ ! -f "$FILE" ]]; then
	exit 1
fi

tar -xzf "$FILE" -C "/opt"
mv /opt/Simplenote-linux-x64 /opt/simplenote

ln -sf "/opt/simplenote/Simplenote" "/usr/bin/Simplenote"

sudo cat > /usr/local/share/applications/simplenote.desktop <<EOL
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Name=Simplenote
Comment=Simplenote for Linux
Exec=/opt/simplenote/Simplenote
Icon=/opt/simplenote/Simplenote.png
Type=Application
StartupNotify=true
Keywords=note;simple;to-do
Categories=Accessories;Office;
EOL

# WPS Office
URL=$(wget "http://wps-community.org/download.html" -O - | tr ' ' '\n' | grep -o "https\?://.*/wps-office-.*$(uname -m).rpm\"" | head -n 1 | rev | cut -c 2- | rev )
 
if [[ "$URL" != "" ]]; then
	dnf -y install "$URL"
else
	exit 1
fi

# VirtualBox
dnf config-manager --add-repo=http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo
dnf -y install binutils gcc make patch libgomp glibc-headers glibc-devel kernel-headers kernel-devel dkms
dnf -y install VirtualBox

# Docker

# Stable repo
sudo dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo

# Remove old version
dnf remove docker \
	  docker-common \
	  container-selinux \
	  docker-selinux \
	  docker-engine

dnf -y install dnf-plugins-core
dnf -y install docker-ce

