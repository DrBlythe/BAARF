#!/bin/bash
#


# Globals
user_name=""
user_pw=""
root_pw=""
host_name=""

function set_root_pw() {
	clear
	echo "-----------------"
	echo "| Root Password |"
	echo "-----------------"
	echo
	pass_ok=0
	while [ $pass_ok -eq 0 ]; do
		echo
		echo -n 'Set password for root: '
		read root_pw
		echo -n 'Confirm password for root: '
		read root_pw_conf
		if [ "$root_pw" = "$root_pw_conf" ]; then
			pass_ok=1
		else
			echo
			echo "Password does not match."
			echo
		fi
	done
	echo "root:${root_pw}" | chpasswd
	echo
	echo
}


function set_timezone() {
	echo "-----------------------"
	echo "| Locale and Timezone |"
	echo "-----------------------"
	echo
	
	# Set locale, symlink to local time
	echo SETTING LOCALE
	echo 'en_US.UTF-8 UTF-8' >>/etc/locale.gen # How presumptuous of me. It's the 4th of July every day YEAAAAAAHHHHH!!!11!
	locale-gen
	clear

	# Get zoneinfo from user
	VALID_REGION=0
	regionArray=$(ls /usr/share/zoneinfo)
	while [ $VALID_REGION -eq 0 ]; do
		ls /usr/share/zoneinfo/
		echo 
		echo -n 'ENTER NAME OF REGION, EXACTLY AS IT APPEARS ABOVE: '
		read MYREGION	
		for region in ${regionArray[@]}; do
			if [ "$region" = $MYREGION ]; then
				VALID_REGION=1
			fi
		done
	done
	echo
	
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

	# Symlink time zone, sync hardware clock
	ln -sf /usr/share/zoneinfo/$MYREGION/$MYCITY /etc/localtime
	hwclock --systohc --utc

	echo
	echo
}

# Create user, password, change hostname
function create_user() {
	echo "-----------------"
	echo "| User Creation |"
	echo "-----------------"
	echo
	echo -n "Enter desired username: "
	read user_name
	echo
	useradd -m -G wheel -s /bin/bash $user_name
	echo $'\n'

	pass_ok=0
	while [ $pass_ok -eq 0 ]; do
		echo
		echo -n "Set password for $user_name: "
		read user_pw
		echo -n "Confirm password for $user_name: "
		read user_pw_conf
		if [ "$user_pw" = "$user_pw_conf" ]; then
			pass_ok=1
		else
			echo
			echo "Password does not match."
			echo
		fi
	done

	echo "${user_name}:${user_pw}" | chpasswd
	echo
	echo

	echo
	echo -n "Enter desired hostname: "
	read host_name
	echo $host_name > /etc/hostname
	echo
	echo
	
	# Add user to wheel
	echo "" >> /etc/sudoers
	echo "## Allow members of group wheel to execute any command" >> /etc/sudoers
	echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
	echo "## Enable password feedback" >> /etc/sudoers
	echo "Defaults env_reset,pwfeedback" >> /etc/sudoers

}


function install_packages() {
	echo "------------------------"
	echo "| Package Installation |"
	echo "------------------------"
	echo

	# Install yay
	yaydir="/home/$user_name/yay"
	pacman -S -y --quiet --noconfirm git
	su "$user_name" -c "git clone https://aur.archlinux.org/yay.git $yaydir"
	chown -R "$user_name" "$yaydir"
	chown -R "$user_name" /package.sh
	cd "$yaydir"
	#su "$user_name" -c "echo $root_pw | makepkg -si"
	sudo -u "$user_name" /package.sh "$user_pw"
	wait
	cd
	rm -rf "$yaydir"
	echo "$user_pw" | sudo -Sv; yes | yay -S polybar-git

	# Install packages
	yay -S -y --quiet --noconfirm bspwm sxhkd grub pulseaudio pulseaudio-alsa pavucontrol networkmanager network-manager-applet xf86-input-libinput mesa xorg xorg-xinit xorg-xbacklight redshift feh htop vim firefox base-devel bash-completion git acpi zathura zathura-djvu zathura-pdf-mupdf wget dmenu netctl dialog dhcpcd

	# Check video drivers
	echo "Checking graphics card..."
	ati=$(lspci | grep VGA | grep ATI)
	nvidia=$(lspci | grep VGA | grep NVIDIA)
	intel=$(lspci | grep VGA | grep Intel)
	amd=$(lspci | grep VGA | grep AMD)
	
	if [ ! -z "$ati" ]; then
	    echo 'Ati graphics detected'
	    yay -S -y --quiet --noconfirm xf86-video-ati
	fi
	if [ ! -z "$nvidia" ]; then
	    echo 'Nvidia graphics detected'
	    yay -S -y --quiet --noconfirm xf86-video-nouveau
	fi
	if [ ! -z  "$intel" ]; then
	    echo 'Intel graphics detected'
	    yay -S -y --quiet --noconfirm xf86-video-intel
	fi
	if [ ! -z  "$amd" ]; then
	    echo 'AMD graphics detected'
	    yay -S -y --quiet --noconfirm xf86-video-amdgpu
	fi

	# Install scripts, dotfiles, themes from github
	git clone https://github.com/s3nko/scripts "/home/${user_name}/.scripts"
	chown -R ${user_name} "/home/${user_name}/.scripts"
	chgrp -R ${user_name} "/home/${user_name}/.scripts"

	git clone https://github.com/s3nko/bspwm-themes "/home/${user_name}/bspwm-themes"
	chown -R ${user_name} "/home/${user_name}/bspwm-themes"
	chgrp -R ${user_name} "/home/${user_name}/bspwm-themes"
	echo "exec bspwm -c ~/.config/bspwm/soren" > "/home/${user_name}/.xinitrc"
	chmod +x "/home/${user_name}/.xinitrc"
	chown -R ${user_name} "/home/${user_name}/.xinitrc"
	chgrp -R ${user_name} "/home/${user_name}/.xinitrc"

	git clone https://github.com/s3nko/doot "/home/${user_name}/doot"
	chown -R "/home/${user_name}/doot"
	chgrp -R "/home/${user_name}/doot"

	echo
	echo

	# Copy theme files over
	#mkdir -p  "/home/${user_name}/pic/pape"
	#cp "/home/${user_name}/bspwm-themes/peachouli/1.png" "/home/${user_name}/pic/pape"

	#mkdir -p "/home/${user_name}/.config/bspwm"
	#cp  "/home/${user_name}/bspwm-themes/peachouli/bspwm/*"  "/home/${user_name}/.config/bspwm/"

	#mkdir -p "/home/${user_name}/.config/sxhkd"
	#cp  "/home/${user_name}/bspwm-themes/peachouli/sxhkd/*"  "/home/${user_name}/.config/sxhkd/"

	#mkdir -p "/home/${user_name}/.config/picom"
	#cp  "/home/${user_name}/bspwm-themes/peachouli/picom/*"  "/home/${user_name}/.config/picom/"

	#mkdir -p "/home/${user_name}/.config/polybar"
	#cp  "/home/${user_name}/bspwm-themes/peachouli/polybar/*"  "/home/${user_name}/.config/polybar"

	#mkdir -p "/home/${user_name}/.config/Xresources"
	#cp  "/home/${user_name}/bspwm-themes/peachouli/Xresources/*"  "/home/${user_name}/.config/Xresources"

	#mkdir -p "/home/${user_name}/.config/dunst"
	#mkdir -p "/home/${user_name}/.config/zathura"

	#cp "/home/${user_name}/bspwm-themes/peachouli/bin/*" "/home/${user_name}/.scripts"

	#mkdir -p "/home/${user_name}/.themes"
	#mkdir -p "/home/${user_name}/.icons"
	#cp "/home/${user_name}/bspwm-themes/peachouli/oomox-peachouli/"  "/home/${user_name}/.themes"
	#cp "/home/${user_name}/bspwm-themes/peachouli/oomox-peachouli-icons/"  "/home/${user_name}/.icons"
}


# Install grub
function install_grub() {
	echo "---------------------"
	echo "| Grub Installation |"
	echo "---------------------"

	echo 
	lsblk -l | grep disk
	echo 
	echo -n 'Enter disk to install grub to (NOT PARTITION): '
	read grub_disk
	grub-install --target=i386-pc /dev/$grub_disk
	grub-mkconfig -o /boot/grub/grub.cfg
	echo
}

function clean_up() {
	# Remove install scripts from root
	# (Exits chroot.sh - back into install.sh - and reboots from that script)
	rm /chroot.sh /package.sh
}

set_root_pw
set_timezone
create_user
install_packages
install_grub
clean_up
