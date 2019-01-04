# DBAARF (I'll figure out what it stands for later)
## An automated Arch Linux install script

### What is it?
DBAARF is an Arch install script that aims to be fairly minimal. It installs the os and sets up an i3wm (gaps!) environment cloned from my dotfiles, as well as programs that are either necessary or that I find myself using every day (there aren't that many). This is by no means anything fancy, but definitely makes the installation and configuration much less time consuming (and makes it luuk guud).

### Screenshots
![screenshot1](https://github.com/DrBlythe/DBAARF/blob/master/screenshot1.png)  
![screenshot2](https://github.com/DrBlythe/DBAARF/blob/master/screenshot2.png)

### Installation:

1: Boot Arch Install media

2: Connect to the internet  

3: Partition your disk. Don't worry about mkfs, mkswap, it is part of the script.  
*I wrote this with a simple partition table in mind (I only use 3: separate partitions for root, swap, and home). You do not have to make a swap. All you do is input the names of the partitions you made for root and home when prompted (swap is automatic). If you want to do this all yourself, just leave the prompts blank.*  

4: Install git ($ pacman -Sy git)  

5: git clone https://github.com/drblythe/DBAARF 

6: cd into DBAARF and execute install.sh  

The rest of the installation is just you hitting enter and typing in responses when prompted (user creation, setting hostname, etc..)  

At the end, you will be told to install the video drivers you need for your system (I'll add this to the script... later :O) I make it list your display devices and the xf86-video drivers from pacman. Install those and then reboot as the script will tell you.  

That's it! After rebooting, log in to your created user account and you are good to go. There is a short post-installation-file in your home directory that you should read as well.
