#!/bin/bash
#
# This script should have been copied to your created user's home directory
# 
# Reminder to run as root
echo
echo -n "RUN WITH SUDO. If you are running as sudo/root hit enter: "
echo
read CONTINUE
echo
echo

# Set locale
echo 'Setting locale...'
localectl set-locale LANG='en_US.UTF-8'
echo
echo

# Set up swap partition if there is one
 echo -n 'Did you set up a swap partition?(y/n): '
 read SWAP
 if [ "$SWAP" = "y"  ]
 then
     echo 'Adding swap partition to fstab...' 
     echo
     SWAPPART=$(sudo fdisk -l | grep swap | cut -d'/' -f3 | cut -d' ' -f1)
     mkswap /dev/$SWAPPART
     MYUUID=$(sudo blkid | grep $SWAPPART | cut -d'"' -f2)
     echo >>/etc/fstab
     echo "# /dev/$SWAPPART" >>/etc/fstab
     echo "UUID=$MYUUID  	none    	swap    	defaults    0 0" >>/etc/fstab
     swapon
 fi

# Todo: Check if SSD 

# Remove install scripts from root
rm /chroot.sh /postinstall.sh

# Guide installation of video drivers
echo
echo
echo
echo "Your display devices: "
lspci | grep VGA
echo
echo
echo "Pacman xf86-video drivers: "
pacman -Ss | grep xf86-video
echo
echo
echo "Install correct video drivers, and you are done! Feel free to remove finish .sh"
