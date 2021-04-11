#! /bin/bash
# Basic if statement

###########################################################################
# Script : userSetup.bash
#
# Description 	: Création et configuration d'un utilisateur, de son
#				  groupe et de son home.
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

# Création du groupe de l'utilisateur (GID)
groupadd -g $groupID $username

# Créer l'utilisateur (UID) et son home. Il est associé au groupe sudo et à son groupe
useradd -mN -G sudo,$username -s /bin/bash -u $userID $username
echo -e "${username}  ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/$username > /dev/null

# Assigner le mot de passe à l'utilisateur
echo -e $username:$password | chpasswd

# Su en root lors de la connection
echo -e "sudo su" >> $userHome/.bashrc