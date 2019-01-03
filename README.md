# DBAARF (I'll figure out what it stands for later)
## An automated Arch Linux install script

### What is it?
DBAARF is an Arch install script that aims to be fairly minimal. It installs the os and sets up an i3wm (gaps!) environment cloned from my dotfiles, as well as programs that are either necessary or that I find myself using every day. 

### Installation:

1: Boot into Arch Install medium  

2: Connect to the internet  

3: Partition your disk. Don't worry about mkfs, mkswap, it is part of the script.  
*I wrote this with a simple partition table in mind (I only use 3: separate partitions for root, swap, and home). You do not have to make a swap. If you want to do this all yourself, just leave the prompts blank when it asks for the partitions that you assigned root and home to.  

4: Install git  

5: git clone https://github.com/drblythe/DBAARF 

6: cd into DBAARF and execute install.sh  

The rest of the installation is just you hitting enter and typing in responses when prompted (user creation, setting hostname, etc..)  

At the end, you will be prompted to reboot. Reboot, log in to your user account that was set up during the installation, and execute finish.sh (as sudo) which will be in your home directory.
I got lazy at the end with video drivers (I'll try to fix this soon), so it ends by listing your display devices and the pacman xf86-video driver list. 
Install necessary drivers, and then you can startx!
