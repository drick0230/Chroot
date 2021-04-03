#! /bin/bash
# Basic if statement

###########################################################################
# Script : SteamInstall.bash
#
# Description : Installation "Manuel" de steam
#				
#
###########################################################################

# Dependencies
sudo apt-get install lib32gcc1

# Create directory for steam in root home
sudo mkdir /root/Steam

# Download and extract SteamCMD in the directory
sudo curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf - -C /root/Steam