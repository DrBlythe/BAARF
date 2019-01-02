#!/bin/bash
#


# Install sudo, add user to wheel
pacman -S sudo
echo "## Allow members of group wheel to execute any command" >> /etc/sudoers
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Create user, password, change hostname
echo -n "Enter desired username: "
read MYUSER
echo
useradd -m -G wheel -s /bin/bash $MYUSER
echo
echo "Enter password for $MYUSER"
echo
passwd $MYUSER
echo
echo -n "Hostname: "
read MYHOST
echo $MYHOST >/etc/hostname


# Install purdy purdy packages
echo
#echo "Installing packages..."
echo
pacman -S i3 pulseaudio pulseaudio-alsa pavucontrol pamixer pasystray xorg dialog redshift feh thunar gvfs-smb lxappearance powertop vim ntfs-3g unzip imagemagick xfce4-terminal chromium compton base-devel bash-completion ttf-ibm-plex ttf-dejavu adobe-source-han-serif-jp-fonts adobe-source-han-sans-jp-fonts git acpi scrot xorg-xinput calibre cmake curl deluge evince mpv youtube-dl thunar-volman fuse-common fuse2 gimp gstreamer gst-libav gst-plugins-bad gst-plugins-good gst-plugins-ugly gvfs ifuse mesa mkvtoolnix-cli gparted perl python3 python2 qt-gstreamer sdl2 sdl2_gfx sdl2_image sdl2_mixer sdl2_net sdl2_ttf wget xorg-xbacklight xorg-xinput

# Git dotfiles, copy finish.sh and move dotfiles to users home directory
chown -R $MYUSER /home/$MYUSER
cp finish.sh /home/$MYUSER/
echo
echo
echo "exec i3" >>/home/$MYUSER/.xinitrc
echo
echo
git clone https://github.com/drblythe/dotfiles
mv dotfiles /home/$MYUSER/
cd /home/$MYUSER/dotfiles
./rice.sh $MYUSER
cd /home/$MYUSER
rm -r /home/$MYUSER/dotfiles
echo

# Guide video driver installation
echo
lspci | grep VGA
echo
echo
pacman -Ss | grep xf86-video
echo
echo "Install the correct video drivers for your machine."
echo "Reboot afterwards, and remove usb."
echo "Login to your user account, and run the script finish.sh that should be in your home directory."
echo "Otherwise, that is it!"




