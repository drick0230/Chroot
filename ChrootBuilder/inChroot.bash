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

userHome=/home/$username

# Donner les droits sudo à l'utilisateur
usermod -a -G sudo $username
echo -e "${username}  ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/$username > /dev/null

# Créer le home de l'utilisateur
mkhomedir_helper $userHome

# Su en root lors de la connection
#touch $userHome/.bashrc
#echo -e "sudo su" >> /etc/bash.bashrc

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