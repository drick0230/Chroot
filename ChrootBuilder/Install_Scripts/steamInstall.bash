#! /bin/bash
# Basic if statement

###########################################################################
# Script : steamInstall.bash
#
# Description 	: Installation de steamcmd et de SDL.
#
# Paramètres	: username	-	Nom de l'utilisateur
#				  password	-	Mot de passe de l'utilisateur
#				  userID	-	UID de l'utilisateur (id -u $username)
#				  groupID	-	GID du groupe de l'utilisateur (id -g $username)
#				  chrootID  -	ID  du chroot
#
#
###########################################################################

username=$1
password=$2
userID=$3
groupID=$4
chrootID=$5

userHome=/home/$username

# Installer Steam
dpkg --add-architecture i386
apt-get -y update
apt-get -y install lib32gcc1
apt-get -y install steamcmd

# Installer SDL
apt-get -qqy install libsdl2-2.0-0:i386