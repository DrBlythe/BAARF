#!/bin/bash
#
# This script is an automated minimal Arch install.
#


# After partitioning, format file systems, and mount
echo
lsblk -l | grep part
echo
echo -n 'Enter name of root partition (i.e. sda1...): '
read ROOTPART
echo -n 'Enter name of /home partition: '
read HOMEPART
echo
mkfs.ext4 /dev/$ROOTPART
mkfs.ext4 /dev/$HOMEPART
mount /dev/$ROOTPART /mnt
mkdir /mnt/home
mount /dev/$HOMEPART /mnt/home


# Install base arch
pacstrap -i /mnt base


# Generate fstab
genfstab -U -p /mnt >> /mnt/etc/fstab


# Check for swap (if exists, add to fstab)
if [ "$(sudo fdisk -l | grep swap | cut -d'/' -f3 | cut -d' ' -f1)" != ""  ]
    then
        echo
        echo 'Swap partition detected: Adding to fstab...'
        echo
        SWAPPART=$(sudo fdisk -l | grep swap | cut -d'/' -f3 | cut -d' ' -f1)
        mkswap /dev/$SWAPPART
        MYUUID=$(sudo blkid | grep $SWAPPART | cut -d'"' -f2)
        echo >>/mnt/etc/fstab
        echo "# /dev/$SWAPPART" >>/mnt/etc/fstab
        echo "UUID=$MYUUID     none        swap        defaults        0 0" >>/mnt/etc/fstab
        swapon
fi


# Chroot into install
cp post-install-notes chroot.sh /mnt
arch-chroot /mnt ./chroot.sh

# Reboot after chroot script finishes
reboot
