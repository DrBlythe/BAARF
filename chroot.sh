#!/bin/bash
#
# Install some packages
echo
echo 'Installing grub, linux headers, wireless packages...'
echo
echo
pacman -S grub-bios linux-headers wpa_supplicant wpa_actiond dialog wireless_tools openssh
echo
echo

# Set locale, symlink to local time
echo
echo
echo
echo 'en_US.UTF-8 UTF-8' >>/etc/locale.gen
locale-gen
echo
echo
echo
echo
ls /usr/share/zoneinfo/
echo
echo
echo
echo
echo -n 'ENTER NAME OF REGION, EXACTLY AS IT APPEARS ABOVE: '
read MYREGION
echo
echo
echo
echo
echo
echo
echo
ls /usr/share/zoneinfo/$MYREGION
echo
echo -n 'ENTER NAME OF CITY, EXACTLY AS IT APPEARS ABOVE: '
read MYCITY
echo
echo
echo
echo
echo
echo
echo
echo
echo

# Symlink time zone, sync hardware clock
echo
ln -sf /usr/share/zoneinfo/$MYREGION/$MYCITY /etc/localtime
hwclock --systohc --utc
systemctl enable sshd.service
echo
echo
echo
echo

# Set root password
echo
echo 'Set password for root: '
echo
passwd
echo
echo
echo
echo
echo

# Install grub
echo
echo
echo
echo
lsblk
echo
echo
echo
echo -n 'Enter DISK to install grub to, NOT PARTITION (i.e. sda or sdb, NOT sda1, sda2): '
read BOOTDISK
echo
echo
echo
echo
echo
echo
echo
echo
echo "Installing grub..."
echo
echo
grub-install --target=i386-pc --recheck /dev/$BOOTDISK
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
grub-mkconfig -o /boot/grub/grub.cfg

# Create user, password, change hostname
echo
echo
echo
echo
echo
echo
echo -n "Enter desired username: "
read MYUSER
echo
useradd -m -G wheel -s /bin/bash $MYUSER
echo
echo
echo "Enter password for $MYUSER"
passwd $MYUSER
echo
echo
echo
echo
echo
echo -n "Enter desired hostname: "
read MYHOST
echo $MYHOST >/etc/hostname
echo
echo
echo
echo
echo
echo

# Install purdy purdy packages
echo
echo
echo "Installing more packages..."
echo "NOTE: During installation, 'Running build hook: [block]' can take a while. It has not (necessarily...) stalled "
echo
echo
# No I am not including neofetch
pacman -S sudo i3 pulseaudio pulseaudio-alsa pavucontrol pamixer pasystray xf86-input-libinput mesa xorg xorg-xinit xorg-xbacklight redshift feh bc thunar thunar-volman fuse2 fuse-common ntfs-3g unzip unrar imagemagick powertop vim xfce4-terminal chromium compton base-devel bash-completion ttf-ibm-plex ttf-dejavu git acpi scrot cmake curl deluge evince mpv youtube-dl mkvtoolnix-cli wget dmenu highlight

# Add user to wheel
echo "## Allow members of group wheel to execute any command" >> /etc/sudoers
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Git dotfiles, copy post-install-notes from root and move dotfiles to users home directory
echo
cp post-install-notes /home/$MYUSER/
echo
echo "Downloading dotfile repository..."
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
chown -R $MYUSER /home/$MYUSER
echo
echo

# Remove install scripts from root
rm /chroot.sh
echo
echo
echo
echo
echo
echo
echo
echo
echo
echo
echo
echo
echo
echo "INSTALLATION COMPLETE! :D"
echo "You may now reboot your system and remove Arch install media."
echo "When you log into your user account, there will be an installation-notes file in your home directory. Read it."
echo
echo
echo
echo
echo "I lied: video drivers are not installed by DBAARF quite yet. Install them now."
echo "Here I am listing your display devices, followed by the pacman xf86-video drivers:"
echo
echo
echo "Your display devices: "
echo
lspci | grep VGA
echo
echo
echo
echo
echo
echo "Pacman xf86-video drivers: "
echo
pacman -Ss | grep xf86-video
echo
echo
echo
echo
echo
echo
echo
