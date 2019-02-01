#!/bin/bash
#



# Set root password
echo
echo 'Set password for root: '
echo
passwd
echo $'\n\n\n\n'



# Set locale, symlink to local time
echo $'\n\n\n\n'
echo 'en_US.UTF-8 UTF-8' >>/etc/locale.gen
locale-gen
echo $'\n\n\n\n'

# Get zoneinfo from user
VALID_REGION=0
regionArray=$(ls /usr/share/zoneinfo)
while [ $VALID_REGION -eq 0 ]
do
	ls /usr/share/zoneinfo/
	echo $'\n\n\n'
	echo -n 'ENTER NAME OF REGION, EXACTLY AS IT APPEARS ABOVE: '
	read MYREGION	

	for region in ${regionArray[@]}; do
		if [ "$region" = $MYREGION ]; then
			VALID_REGION=1
		fi
	done

echo $'\n\n\n'

if [ -d /usr/share/zoneinfo/$MYREGION ]; then
	VALID_CITY=0
	cityArray=$(ls /usr/share/zoneinfo/$MYREGION)
	while [ $VALID_CITY -eq 0 ]; do
		ls /usr/share/zoneinfo/$MYREGION/
		echo $'\n\n\n'
		echo -n 'ENTER NAME OF CITY, EXACTLY AS IT APPEARS ABOVE: '
		read MYCITY
		for city in ${cityArray[@]}; do
			if [ "$city" = $MYCITY ]; then
				VALID_CITY=1;
			fi
		done
	done
fi

echo $'\n\n\n'


# Symlink time zone, sync hardware clock
echo
ln -sf /usr/share/zoneinfo/$MYREGION/$MYCITY /etc/localtime
hwclock --systohc --utc
echo $'\n\n\n\n'




# Install packages
echo $'\n'
echo "Installing packages..."
echo $'\n'
# NO NEOFETCH
pacman -S sudo i3 pulseaudio pulseaudio-alsa pavucontrol pamixer pasystray networkmanager network-manager-applet xf86-input-libinput mesa xorg xorg-xinit xorg-xbacklight redshift bc ranger w3m feh fuse2 fuse-common ntfs-3g dosfstools unzip unrar imagemagick htop tlp vim xfce4-terminal firefox thunderbird base-devel bash-completion ttf-ibm-plex ttf-dejavu adobe-source-han-sans-jp-fonts adobe-source-han-serif-jp-fonts git acpi scrot cmake curl zathura zathura-djvu zathura-pdf-mupdf mpv youtube-dl mkvtoolnix-cli wget dmenu sysstat python python-requests



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
echo "## Enable password feedback" >> /etc/sudoers
echo "Defaults env_reset,pwfeedback" >> /etc/sudoers



# Git dotfiles, copy post-install-notes from root and move dotfiles to users home directory
echo
cp post-install-notes /home/$MYUSER/
rm /post-install-notes
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



# Remove install scripts from root
# (Exits chroot.sh - back into install.sh - and reboots from that script)
rm /chroot.sh
echo $'\n\n\n\n'
echo $'\n\n\n\n'
echo "INSTALLATION COMPLETE! :D"
echo
echo "When you log into your user account, there will be an installation-notes file in your home directory. Read it."
echo
echo "You may now reboot and remove installation media."
echo "System will reboot in 10 seconds."
echo $'\n\n\n\n'
sleep 10
