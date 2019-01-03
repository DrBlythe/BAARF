#!/bin/bash
#
# Install some packages
echo
echo 'Installing grub, linux headers, wireless packages...'
echo
echo
pacman -S grub-bios linux-headers wpa_supplicant wireless_tools openssh
echo
echo

# Set locale, symlink to local time
echo
echo "Setting locale... (Did you just assume my language??)"
echo
echo 'en_US.UTF-8 UTF-8' >>/etc/locale.gen
locale-gen
echo
echo
echo "(But you didn't assume my location?)"
echo
ls /usr/share/zoneinfo/
echo
echo -n 'ENTER NAME OF REGION, EXACTLY AS IT APPEARS ABOVE: '
read MYREGION
echo
echo
ls /usr/share/zoneinfo/$MYREGION
echo
echo -n 'ENTER NAME OF CITY, EXACTLY AS IT APPEARS ABOVE: '
read MYCITY
echo
echo

# Symlink time zone, sync hardware clock
echo
ln -sf /usr/share/zoneinfo/$MYREGION/$MYCITY /etc/localtime
hwclock --systohc --utc
systemctl enable sshd.service
echo

# Set root password
echo
echo 'Set password for root: '
echo
passwd
echo

# Install grub
echo
echo
lsblk
echo
echo
echo -n 'Enter boot DISK, NOT PARTITION (i.e. sda or sdb, NOT sda1, sda2): '
echo
read BOOTDISK
echo
echo
echo "Installing grub..."
echo
grub-install --target=i386-pc --recheck /dev/$BOOTDISK
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
grub-mkconfig -o /boot/grub/grub.cfg

# Create user, password, change hostname
echo
echo
echo -n "Enter desired username: "
read MYUSER
echo
useradd -m -G wheel -s /bin/bash $MYUSER
echo
echo
echo -n "Enter password for $MYUSER"
echo
passwd $MYUSER
echo
echo
echo -n "Enter desired hostname: "
read MYHOST
echo $MYHOST >/etc/hostname

# Install purdy purdy packages
echo
echo
echo "Installing more packages..."
echo
echo
pacman -S sudo i3 pulseaudio pulseaudio-alsa pavucontrol pamixer pasystray xorg xorg-xinit dialog redshift feh bc thunar powertop vim ntfs-3g unzip imagemagick xfce4-terminal chromium compton base-devel bash-completion ttf-ibm-plex ttf-dejavu adobe-source-han-serif-jp-fonts adobe-source-han-sans-jp-fonts git acpi scrot xorg-xinput calibre cmake curl deluge evince mpv youtube-dl thunar-volman fuse-common fuse2 gimp gstreamer mesa mkvtoolnix-cli gparted perl python3 python2 qt wget dmenu xorg-xbacklight

# Add user to wheel
echo "## Allow members of group wheel to execute any command" >> /etc/sudoers
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Git dotfiles, copy finish.sh and move dotfiles to users home directory
echo
cp finish.sh /home/$MYUSER/
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
echo "You may now reboot your system and remove Arch install media."
echo "After reboot, log into your created user normally. There is a short script in your home directory called finish.sh."
echo "Run that that as root, and after installing video drivers you are free to startx!"
