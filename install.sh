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
echo

# Format filesystems
mkfs.ext4 /dev/$ROOTPART

# Mount partitions
mount /dev/$ROOTPART /mnt

# Check for swap
if [ "$(sudo fdisk -l | grep swap | cut -d'/' -f3 | cut -d' ' -f1)" != ""  ]
    then
        echo
        echo 'Swap partition detected: Adding to fstab...'
        echo
        mkswap /dev/$SWAPPART
        swapon
fi

# Install base arch
pacstrap -i /mnt base linux linux-firmware --quiet --noconfirm


# Generate fstab
genfstab -U -p /mnt >> /mnt/etc/fstab


# Chroot into install
cp post-install-notes chroot.sh /mnt
arch-chroot /mnt ./chroot.sh

# Reboot after chroot script finishes
#reboot
