#!/bin/bash
#
# This script is an automated minimal Arch install.
#

# After partitioning, format file systems, and mount
echo
lsblk
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

# Chroot into install
cp postinstall.sh finish.sh chroot.sh /mnt
arch-chroot /mnt ./chroot.sh

