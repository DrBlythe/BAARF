#!/bin/bash
#
# Install some packages
pacman -S grub-bios linux-headers wpa_supplicant wireless_tools openssh

# Set locale, symlink to local time
echo 'en_US.UTF-8 UTF-8' >>/etc/locale.gen
locale-gen
echo
echo
ls /usr/share/zoneinfo/
echo
echo -n 'ENTER NAME OF REGION FROM ABOVE: '
read MYREGION
echo
ls /usr/share/zoneinfo/$MYREGION
echo
echo -n 'ENTER NAME OF CITY FROM ABOVE: '
read MYCITY
echo

ln -sf /usr/share/zoneinfo/$MYREGION/$MYCITY /etc/localtime
hwclock --systohc --utc
systemctl enable sshd.service


# Set root password
echo
echo 'Set password for root: '
passwd

# Install grub
echo
lsblk
echo
echo
echo -n 'Enter boot DISK, NOT PARTITION (i.e. sda or sdb, NOT sda1, sda2): '
echo
read BOOTDISK
grub-install --target=i386-pc --recheck /dev/$BOOTDISK
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
grub-mkconfig -o /boot/grub/grub.cfg

# Run post installation
/postinstall.sh
