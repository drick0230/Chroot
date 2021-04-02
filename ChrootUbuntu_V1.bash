#! /bin/bash
# Basic if statement

###########################################################################
# Script : ChrootSetup.bash
#
# Description : Création et configuration d'un utilisateur avec son home
#				en tant que Chroot et installation de programmes.
#				Le home si situe dans /srv/chroot/
#				L'utilisateur a accès à sudo dans le chroot
#				Steam est installer dans le chroot
#
# Dépendances : schroot et debootstrap
#
###########################################################################

# Constant Variables

#### Création de l'utilisateur ####
# Demander le nom de l'utilisateur
read -p "Nom d'utilisateur:" username
read -s -p "Mot de passe:" password
echo -e '\n'

userDir=/srv/chroot/$username

# Create user
useradd $username

# Password
echo -e $username:$password | sudo chpasswd

# Créer son chroot
umount $userDir/etc/resolv.conf
umount $userDir/proc
rm -r $userDir
mkdir -p $userDir

#### Installer Ubuntu dans le chroot (schroot) ####
# Exemple de config pour un user (Dans /etc/schroot/chroot.d/user10.conf)
echo -e "[${username}]" | sudo tee /etc/schroot/chroot.d/$username.conf > /dev/null
echo -e "description=Ubuntu Focal for ${username}" | sudo tee -a /etc/schroot/chroot.d/$username.conf > /dev/null
echo -e "directory=${userDir}" | sudo tee -a /etc/schroot/chroot.d/$username.conf > /dev/null
echo -e "root-users=${username}" | sudo tee -a /etc/schroot/chroot.d/$username.conf > /dev/null
echo -e "root-groups=${username}" | sudo tee -a /etc/schroot/chroot.d/$username.conf > /dev/null
echo -e "type=directory" | sudo tee -a /etc/schroot/chroot.d/$username.conf > /dev/null

debootstrap --arch=amd64 focal $userDir http://archive.ubuntu.com/ubuntu/

# Add internet access (Not working?)
cp --parents /run/systemd/resolve/stub-resolv.conf $userDir
cp --parents /etc/resolv.conf $userDir

# Add process management
mkdir $userDir/proc
mount -o bind /proc $userDir/proc

#### Entrer dans le chroot #######################
cp inChroot.bash $userDir
chroot $userDir /bin/bash inChroot.bash $username $password


#### Sortir du chroot ###########################
#exit" >> $userDir/InChroot.bash


# Restart SSh service (Apply config)
sudo /etc/init.d/ssh restart
