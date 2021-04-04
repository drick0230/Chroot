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
apt-get -y install tightvncserver
vncserver :$chrootID
vncserver -kill :$chrootID


# Démarrer xfce4 au démmarage de VNC server (Configuration dans /root/.vnc/xstartup)
mv /root/.vnc/xstartup /root/.vnc/xstartup.bak # /root/.vnc/xstartup par défaut en backup
echo "#! /bin/bash" > /root/.vnc/xstartup
echo "xrdb $HOME/.Xresources" >> /root/.vnc/xstartup
echo "startxfce4 &" >> /root/.vnc/xstartup
chmod 755 /root/.vnc/xstartup # Give rx right to everyone