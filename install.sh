#!/bin/bash
#

disk_list=""
disk_install=""
swap_size=0
swap_part=""
root_part=""

# Get confirmation
function get_confirmation() {
	ret=-1
	echo $1
	echo -n "Enter y/n to confirm: "
	while [ $ret -lt 0 ]; do
		read response
		if [ "$response" == "y" ] || [ "$response" == "yes" ]; then
			ret=0
		elif [ "$response" == "n" ] || [ "$response" == "no" ]; then
			ret=1
		else
			echo -n "Got stones in your ears? It's y/n only: "
		fi
	done
	return $ret
}

# Check if input is integer
function check_int() {
	re='^[0-9]+$'
	if ! [[ $1 =~ $re ]] ; then
		return 1
	else
		return 0
	fi
}

# Display title and info about installer
function title() {
	clear
	echo "-----------------------------"
	echo "| Arch Linux Quick Installer |"
	echo "----------------------------"
	echo "This process will completely obliterate anything on the drive you select to install on!"
	echo "This only does MBR/BIOS since I don't have a need to set up an EFI boot partition."
	echo "GPT is bloat."
	echo
	echo
}

function disk_selection() {
	echo "---------------------"
	echo "| 1. Disk Selection |"
	echo "---------------------"
	echo

	# Get list of drives
	disk_list=$(lsblk -l | grep disk | cut -d ' ' -f1)

	lsblk -l | grep disk

	# Get disk input
	valid_disk=0
	while [ $valid_disk -eq 0 ]; do
		echo
		echo -n "Enter name of disk you wish to install to [ "
		echo -n $disk_list
		echo -n " ]: "

		read disk_install
		for disk in $disk_list; do
			if [ "$disk_install" == "$disk" ]; then
				valid_disk=1
			fi
		done
		echo
		if [ $valid_disk -eq 0 ]; then
			echo "INVALID DISK SELECTION"
		fi
	done
	echo 
}

function swap() {
	echo "-----------"
	echo "| 3. Swap |"
	echo "-----------"
	echo
	valid_swap_size=0

	while [ $valid_swap_size -eq 0 ]; do
		echo -n "Enter size of swap partition in Mb ('0' for no swap, '8000' for 8Gb): "
		read swap_size
		if check_int "$swap_size"; then
			valid_swap_size=1
		else
			echo
			echo "Enter a non-negative integer value"
		fi
		echo
	done
	echo
}

function filesystem() {
	echo -e "------------------"
	echo -e "| 4. Filesystems |"
	echo -e "------------------"
	echo
	echo "A choice? You get ext4 for root partition."
	echo "Oh, you wanted butterfs, xfs or something? Freedom?"
	echo ">>> https://wiki.archlinux.org/index.php/Installation_Guide"
	echo

	get_confirmation "You are about to format and lose everything on disk ${disk_install}."
	if [ $? -eq 1 ]; then
		echo
		echo "Quitting. Nothing written to disk yet."
		echo "I was just beginning to think we were friends."
		echo
		exit 1
	fi

	# Wipe disk
	wipefs --all "/dev/${disk_install}"
	sync

	# No swap -> Use entire disk for root
	if [ $swap_size -eq 0 ]; then
		echo "CREATING ROOT PARTITION WITH FULL DISK..."
		(echo o; echo n; echo p; echo 1; echo ""; echo ""; sleep 0.5; echo w; echo q) | fdisk /dev/$disk_install
		wait
		sync
		root_part="$(lsblk -l | grep $disk_install | grep part | cut -d ' ' -f1 | tail -n 1)"
		echo "Created root partition on $root_part"
		echo
	# Swap -> Make swap first, then use remaining for root
	else
		echo "CREATING SWAP PARTITION [$swap_size MB]..."
		echo "CREATING ROOT PARTITION [remaining space]..."
		(echo o; echo n; echo p; echo 1; echo ""; echo "+${swap_size}M"; echo n; echo p; echo 2; echo ""; echo ""; sleep 0.5; echo w; echo q) | fdisk /dev/$disk_install
		wait
		sync
		swap_part="$(lsblk -l | grep $disk_install | grep part | cut -d ' ' -f1 | head -n 1)"
		root_part="$(lsblk -l | grep $disk_install | grep part | cut -d ' ' -f1 | tail -n 1)"
		echo
	fi

	echo "MAKING FILESYSTEMS..."
	if [ $swap_size -ne 0 ]; then
		echo
		echo "Swap on partition $swap_part"
		echo
		mkswap -f "/dev/${swap_part}"
		swapon "/dev/${swap_part}"
	fi
	echo
	echo "ext4 filesystem on $root_part"
	echo
	mkfs.ext4 -F "/dev/${root_part}"
	echo
	echo "MOUNTING FILESYSTEMS..."
	mount "/dev/${root_part}" /mnt
	echo
	echo
}

function install_base() {
	echo -e "--------------------------"
	echo -e "| 5. Install Base System | "
	echo -e "--------------------------"
	echo
	pacstrap /mnt base linux linux-firmware
}

function pre_chroot() {
	echo "CREATING FSTAB FOR NEW SYSTEM"
	genfstab -U /mnt >> /mnt/etc/fstab
	cp post-install-notes chroot.sh /mnt
}

function prompt_reboot() {
	echo -e "------------"
	echo -e "| COMPLETE |"
	echo -e "------------"
	echo
	echo "Installation complete!"
	echo "Remove usb and reboot your system homey."
}


title
disk_selection
swap
filesystem
install_base
pre_chroot
#arch-chroot /mnt ./chroot.sh
prompt_reboot

# if [ "$(sudo fdisk -l | grep swap | cut -d'/' -f3 | cut -d' ' -f1)" != ""  ]
#     then
#         echo
#         echo 'Swap partition detected: Adding to fstab...'
#         echo
#         SWAPPART=$(sudo fdisk -l | grep swap | cut -d'/' -f3 | cut -d' ' -f1)
#         mkswap /dev/$SWAPPART
#         MYUUID=$(sudo blkid | grep $SWAPPART | cut -d'"' -f2)
#         echo >>/mnt/etc/fstab
#         echo "# /dev/$SWAPPART" >>/mnt/etc/fstab
#         echo "UUID=$MYUUID     none        swap        defaults        0 0" >>/mnt/etc/fstab
#         swapon
# fi
# 
# 
# # Chroot into install
# cp post-install-notes chroot.sh /mnt
# arch-chroot /mnt ./chroot.sh
# 
# # Reboot after chroot script finishes
# reboot
# 
