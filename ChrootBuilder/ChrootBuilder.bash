#! /bin/bash
# Basic if statement

###########################################################################
# Script : ChrootSetup.bash
#
# Description : Création et configuration d'un utilisateur avec son home
#				en tant que Chroot et installation de programmes.
#				Le chroot est une copie d'un template qui doit être généré
#				avec TemplateBuilder.sh
#
#				-Ajout du groupe chrooted dans sshd_config
#				-Le home se situe dans /srv/chroot/
#				-L'utilisateur a accès à sudo dans le chroot
#				-Steam est installer dans le chroot
#
#
# Dépendances : schroot et debootstrap
#
###########################################################################

# Constant Variables
chrootTemplateDir="/srv/chrootTemplate"
chrootDir="/srv/chroot/"

# Create the chroot directory if it didnt exist
if [ -d $chrootDir ]
	then
		echo "${chrootDir} exist. [OK]"
	else
		echo "${chrootDir} did not exist. mkdir ${chrootDir}"
		mkdir $chrootDir
fi

port=$(expr $(ls $chrootDir | wc -l) + 1)

#### Création de l'utilisateur ####
# Demander le nom de l'utilisateur
read -p "Nom d'utilisateur:" username
read -s -p "Mot de passe:" password
echo -e '\n'

userDir=$chrootDir/$username
userHome=$userDir/home/$username

if [ -z "$(cat /etc/ssh/sshd_config | grep "Match Group chrooted")" ]
	then
		# Created chrooted group
		addgroup chrooted
		
		# Add users to sshd_config
		echo -e '\n' | sudo tee -a /etc/ssh/sshd_config > /dev/null
		echo -e "Match Group chrooted" | sudo tee -a /etc/ssh/sshd_config > /dev/null
		echo -e "\tChrootDirectory ${chrootDir}/%u" | sudo tee -a /etc/ssh/sshd_config > /dev/null
fi


# Create user
useradd $username
usermod -a -G chrooted $username

# Password
echo -e $username:$password | chpasswd

# Créer son chroot
umount $userDir/etc/resolv.conf
umount $userDir/proc
rm -r $userDir

# Configuration de schroot pour l'utilisateur (Dans /etc/schroot/chroot.d/$username.conf)
echo -e "[${username}]" | tee /etc/schroot/chroot.d/$username.conf > /dev/null
echo -e "description=Ubuntu Focal for ${username}" | tee -a /etc/schroot/chroot.d/$username.conf > /dev/null
echo -e "directory=${userDir}" | tee -a /etc/schroot/chroot.d/$username.conf > /dev/null
echo -e "root-users=${username}" | tee -a /etc/schroot/chroot.d/$username.conf > /dev/null
echo -e "root-groups=${username}" | tee -a /etc/schroot/chroot.d/$username.conf > /dev/null
echo -e "type=directory" | tee -a /etc/schroot/chroot.d/$username.conf > /dev/null


#### Installer Ubuntu dans le chroot (schroot) ####
# Remove process management from Template (Need to be mounted later, not copied)
umount $chrootTemplateDir/proc

# Copier le Template en tant que home
echo -e "Copy ${chrootTemplateDir} in ${userDir} (Can take a while) ..."
cp -a $chrootTemplateDir $userDir

#### Configuration de Ubuntu dans le chroot ####
# Add user info in the chroot
cat /etc/shadow | grep "$username:" >> $userDir/etc/shadow
cat /etc/passwd | grep "$username:" >> $userDir/etc/passwd
cat /etc/group | grep "$username:" >> $userDir/etc/group

# Add internet access (Not working?)
cp --parents /run/systemd/resolve/stub-resolv.conf $userDir
cp --parents /etc/resolv.conf $userDir

# Add process management
mkdir $userDir/proc
mount -o bind /proc $userDir/proc

#### Installation de logiciels dans le chroot ####
#### Lancer inChroot.bash dans le chroot en root #######################
cp inChroot.bash $userDir
chroot $userDir /bin/bash inChroot.bash $username $password $port

# Restart SSh service (Apply config)
/etc/init.d/ssh restart
