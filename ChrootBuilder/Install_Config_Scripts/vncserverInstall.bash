#! /bin/bash
# Basic if statement

###########################################################################
# Script : vncserverInstall.bash
#
# Description : Installation et configuration de tightvncserver.
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

# Installer VNC server
apt-get update
apt-get -qqy install xfce4 xfce4-goodies
apt-get -qqy install tightvncserver
echo vncserver :$chrootID
vncserver -kill :$chrootID
mv /root/.vnc/xstartup /root/.vnc/xstartup.bak

# root/.vnc/xstartup !!!Première ligne non fonctionnel!!!

#echo -e "xrdb $HOME/.Xresources" | sudo tee -a /root/.vnc/xstartup > /dev/null
#echo -e "startxfce4 &" | sudo tee -a /root/.vnc/xstartup > /dev/null