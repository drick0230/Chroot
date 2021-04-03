#! /bin/bash
# Basic if statement

###########################################################################
# Script : sambaInstall.bash
#
# Description : Téléchargement, installation et configuration de Samba.
#
###########################################################################

# Constant Variables
sharedFolderName=SharedFolder
sharedFolderPath=/media/$sharedFolderName

# Install samba
apt-get update
apt-get -qy install samba

# Create the directory of the Shared Folder
mkdir $sharedFolderPath

# Config for the Shared Folder (in /etc/samba/smb.conf)
echo -e '\n' >> /etc/samba/smb.conf
echo -e "[${sharedFolderName}]" >> /etc/samba/smb.conf
echo -e "\tcomment = Samba on Ubuntu" >> /etc/samba/smb.conf
echo -e "\tpath = ${sharedFolderPath}" >> /etc/samba/smb.conf
echo -e "\tread only = no" >> /etc/samba/smb.conf
echo -e "\tbrowsable = yes" >> /etc/samba/smb.conf

# Restart Samba (Apply Config)
service smbd restart
ufw allow samba

# Add samba user (Need to be a real system user)
read -p "Nom d'utilisateur:" username
smbpasswd -a $username