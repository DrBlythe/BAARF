#!/bin/bash
#


# Set locale, symlink to local time
echo $'\n\n\n\n'
echo 'en_US.UTF-8 UTF-8' >>/etc/locale.gen
locale-gen
echo $'\n\n\n\n'
ls /usr/share/zoneinfo/
echo $'\n\n\n\n'
echo -n 'ENTER NAME OF REGION, EXACTLY AS IT APPEARS ABOVE: '
read MYREGION
echo $'\n\n\n\n'
echo $'\n\n\n\n'
ls /usr/share/zoneinfo/$MYREGION
echo $'\n\n\n\n'
echo -n 'ENTER NAME OF CITY, EXACTLY AS IT APPEARS ABOVE: '
read MYCITY
echo $'\n\n\n\n'
echo $'\n\n\n\n'



# Symlink time zone, sync hardware clock
echo
ln -sf /usr/share/zoneinfo/$MYREGION/$MYCITY /etc/localtime
hwclock --systohc --utc
systemctl enable sshd.service
echo $'\n\n\n\n'



# Set root password
echo
echo 'Set password for root: '
echo
passwd
echo $'\n\n\n\n'



# Install packages
echo $'\n'
echo "Installing packages..."
echo "NOTE: During installation, 'Running build hook: [block]' can take a while. It has not (necessarily...) stalled "
echo $'\n'
# NO NEOFETCH 
pacman -S grub-bios linux-headers wpa_supplicant wpa_actiond dialog wireless_tools openssh sudo i3 pulseaudio pulseaudio-alsa pavucontrol pamixer pasystray xf86-input-libinput mesa xorg xorg-xinit xorg-xbacklight redshift bc ranger w3m feh sxiv ntp fuse2 fuse-common ntfs-3g unzip unrar imagemagick powertop vim xfce4-terminal firefox thunderbird compton base-devel bash-completion ttf-ibm-plex ttf-dejavu git acpi scrot cmake curl deluge zathura zathura-djvu zathura-pdf-mupdf mpv youtube-dl mkvtoolnix-cli wget dmenu highlight dunst



# Install grub
echo $'\n\n\n\n'
lsblk -l | grep disk
echo $'\n\n\n\n'
echo -n 'Enter disk to install grub to (i.e. sda): '
read BOOTDISK
echo $'\n\n\n\n'
echo $'\n\n\n\n'
echo "Installing grub..."
echo $'\n'
grub-install --target=i386-pc --recheck /dev/$BOOTDISK
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
grub-mkconfig -o /boot/grub/grub.cfg



# Create user, password, change hostname
echo $'\n\n\n\n'
echo -n "Enter desired username: "
read MYUSER
echo
useradd -m -G wheel -s /bin/bash $MYUSER
echo $'\n'
echo "Enter password for $MYUSER"
passwd $MYUSER
echo $'\n\n\n\n'
echo -n "Enter desired hostname: "
read MYHOST
echo $MYHOST >/etc/hostname
echo $'\n\n\n\n'



# Add user to wheel
echo "## Allow members of group wheel to execute any command" >> /etc/sudoers
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
echo "## Enable password feedback"
echo "Defaults env_reset,pwfeedback" >> /etc/sudoers



# Git dotfiles, copy post-install-notes from root and move dotfiles to users home directory
echo
cp post-install-notes /home/$MYUSER/
echo $'\n'
echo "Downloading dotfile repository..."
echo $'\n'
echo "exec i3" >>/home/$MYUSER/.xinitrc
echo $'\n'
git clone https://github.com/drblythe/dotfiles
mv dotfiles /home/$MYUSER/
cd /home/$MYUSER/dotfiles
./rice.sh $MYUSER
cd /home/$MYUSER
rm -r /home/$MYUSER/dotfiles
chown -R $MYUSER /home/$MYUSER
echo $'\n'



# Install video drivers
ATI=$(lspci | grep VGA | grep ATI)
NVIDIA=$(lspci | grep VGA | grep NVIDIA)
INTEL=$(lspci | grep VGA | grep Intel)
AMD=$(lspci | grep VGA | grep AMD)

if [ ! -z "$ATI" ]; then
    echo 'Ati graphics detected'
    pacman -S xf86-video-ati
fi

if [ ! -z "$NVIDIA" ]; then
    echo 'Nvidia graphics detected'
    pacman -S xf86-video-nouveau
fi

if [ ! -z  "$INTEL" ]; then
    echo 'Intel graphics detected'
    pacman -S xf86-video-intel
fi

if [ ! -z  "$AMD" ]; then
    echo 'AMD graphics detected'
    pacman -S xf86-video-amdgpu
fi



# Remove install scripts from root, finish, reboot after delay
rm /chroot.sh
echo $'\n\n\n\n'
echo $'\n\n\n\n'
echo "INSTALLATION COMPLETE! :D"
echo "When you log into your user account, there will be an installation-notes file in your home directory. Read it."
echo 
echo "System will automatically reboot in 10 seconds..."
echo $'\n\n\n\n'
sleep 10
reboot
