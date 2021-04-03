#! /bin/bash
# Basic if statement

###########################################################################
# Script : inChroot.bash
#
# Description : Création et configuration d'un utilisateur et installation
#				de programmes à l'intérieur d'un chroot.
#
#
###########################################################################


username=$1
password=$2
port=$3
userID=$4
groupID=$5

userHome=/home/$username

# Créer l'utilisateur (sudo), son groupe et son home
useradd -mU -G sudo -s /bin/bash -u $userID $username
echo -e "${username}  ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/$username > /dev/null

# Assigner le mot de passe à l'utilisateur
echo -e $username:$password | chpasswd

# Assigner le bon GID au groupe de l'utilisateur
oldGroupID=$(id -g $username)
groupmod -g $groupID $username
find / -group $oldGroupID -exec chgrp -h $username {} \; # Appliquer à tous les fichiers

# Su en root lors de la connection
echo -e "sudo su" >> $userHome/.bashrc

# Installer Steam
dpkg --add-architecture i386
apt -y update
apt -y install lib32gcc1 steamcmd

# Installer SDL
apt -y install libsdl2-2.0-0:i386

# Installer VNC server
apt-get update
apt-get -y install xfce4 xfce4-goodies
apt-get -y install tightvncserver
echo -e $password | vncserver :$port
vncserver -kill :$port
mv /root/.vnc/xstartup /root/.vnc/xstartup.bak

# root/.vnc/xstartup !!!Première ligne non fonctionnel!!!

#echo -e "xrdb $HOME/.Xresources" | sudo tee -a /root/.vnc/xstartup > /dev/null
#echo -e "startxfce4 &" | sudo tee -a /root/.vnc/xstartup > /dev/null