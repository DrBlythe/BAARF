#!/bin/bash
#
# This script should have been copied to your created user's home directory
# Run with sudo
# 
# Reminder to reconnect to wireless
echo
echo "RUN WITH SUDO"
echo
echo -n "Friendly reminder to reconnect to internet... Well have you?? There are packages inbound soldier! If you have already AND ARE RUNNING WITH SUDO OR ROOT hit enter."
read CONTINUE
echo
echo

# Set locale
localectl set-locale LANG='en_US.UTF-8'

# Set up swap partition if there is one
 echo -n 'Did you set up a swap partition?(y/n): '
 read SWAP
 if [ "$SWAP" = "y"  ]
 then
     echo 'Adding swap partition to fstab...' 
     SWAPPART=$(sudo blkid | grep swap | cut -d'/' -f3 | cut -d':' -f1)
     MYUUID=$(sudo blkid | grep swap | cut -d'"' -f2)
     echo >>/etc/fstab
     echo "# /dev/$SWAPPART" >>/etc/fstab
     echo "UUID=$MYUUID  	none    	swap    	defaults    0 0" >>/etc/fstab
     swapon
 fi

# Todo: Check if SSD 

# Remove install scripts from root
rm /chroot.sh /postinstall.sh

# Finish
echo "Install completed: You can delete finish.sh now"
