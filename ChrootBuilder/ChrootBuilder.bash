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

#### Constant Variables ####
chrootTemplateDir="/srv/chrootTemplate"
chrootDir="/srv/chroot/"
chrootGroup=chrooted
chrootShell=/bin/bash



#### Création du groupe chrooted et ajout de celui-ci dans les configurations de SSH ####
if [ -z "$(cat /etc/ssh/sshd_config | grep "Match Group ${chrootGroup}")" ]
	then
		echo "${chrootGroup} did not exist. [...]"
		# Create chroot group
		addgroup $chrootGroup
		
		# Add chroot group to sshd_config
		echo -e '\n' | sudo tee -a /etc/ssh/sshd_config > /dev/null
		echo -e "Match Group ${chrootGroup}" | sudo tee -a /etc/ssh/sshd_config > /dev/null
		echo -e "\tChrootDirectory ${chrootDir}/%u" | sudo tee -a /etc/ssh/sshd_config > /dev/null
		
		echo "${chrootGroup} added. [OK]"
		echo "${chrootGroup} added to sshd_config. [OK]"
fi



#### Création du répertoire de stockage des chroot ####
if [ -d $chrootDir ]
	then
		echo "${chrootDir} exist. [OK]"
	else
		echo "${chrootDir} did not exist. mkdir ${chrootDir}"
		mkdir $chrootDir
fi

port=$(expr $(ls $chrootDir | wc -l) + 1) # Identifiant de la chroot



####### Création de l'utilisateur #######
# Demander le nom de l'utilisateur
read -p "Nom d'utilisateur:" username	# Nom de l'utilisateur
read -s -p "Mot de passe:" password		# Mot de passe de l'utilisateur
echo -e '\n'

userDir=$chrootDir/$username 			# Répertoire du chroot de l'utilisateur

# Création de l'utilisateur, ajout dans le goupe chroot et changement de son shell pour Bash
if [ -n "$(cat /etc/passwd | grep "${username}:")" ]
	then
		echo "${username} exist. [...]"
		usermod -a -G $chrootGroup -s $chrootShell $username # Create user with chrooted group and chroot shell
		echo "${username} added to ${chrootGroup}. [OK]"
		echo "${username} shell change to ${chrootShell}. [OK]"
	else
		echo "${username} did not exist. [...]"
		useradd -G $chrootGroup -s $chrootShell $username # Add user to chrooted and change shell to chroot shell
		echo "${username} added. [OK]"
fi

# Change the password of the user
echo -e $username:$password | chpasswd



#### Supprimer les anciennes installation du chroot de l'utilisateur ####
if [ -d $userDir ]
	then
		echo "${userDir} exist. Remove it (Can take a while) [...]"

		# Remove process management from user chroot
		if mountpoint -q $userDir/proc
			then
				echo "${userDir}/proc mounted. [...]"
				umount $userDir/proc
		fi
		echo "${userDir}/proc unmounted. [OK]"
		
		# Remove user chroot
		rm -r $userDir
		
		echo "${userDir} removed. [OK]"
	else
		echo "${userDir} did not exist. [OK]"
fi



#### Configuration de schroot pour l'utilisateur (Dans /etc/schroot/chroot.d/$username.conf) ####
echo -e "[${username}]" | tee /etc/schroot/chroot.d/$username.conf > /dev/null
echo -e "description=Ubuntu Focal for ${username}" | tee -a /etc/schroot/chroot.d/$username.conf > /dev/null
echo -e "directory=${userDir}" | tee -a /etc/schroot/chroot.d/$username.conf > /dev/null
echo -e "root-users=${username}" | tee -a /etc/schroot/chroot.d/$username.conf > /dev/null
echo -e "root-groups=${username}" | tee -a /etc/schroot/chroot.d/$username.conf > /dev/null
echo -e "type=directory" | tee -a /etc/schroot/chroot.d/$username.conf > /dev/null



#### Installer Ubuntu dans le chroot (Copie du Template) ####
# Remove process management from Template (Need to be mounted later, not copied)
if mountpoint -q $chrootTemplateDir/proc
	then
		echo "${chrootTemplateDir}/proc mounted. [...]"
		umount $chrootTemplateDir/proc
		rm -r $chrootTemplateDir/proc
fi
echo "${chrootTemplateDir}/proc unmounted and removed. [OK]"

# Copier le Template en tant que chroot pour l'utilisateur
echo -e "Copy ${chrootTemplateDir} in ${userDir} (Will take a while) [...]"
cp -a $chrootTemplateDir $userDir
echo -e "${chrootTemplateDir} copiedvi in ${userDir} [OK]"

#### Configuration de Ubuntu dans le chroot ####
# Add internet access
cp --parents /run/systemd/resolve/stub-resolv.conf $userDir
cp --parents /etc/resolv.conf $userDir

# Add process management
mkdir $userDir/proc
mount -o bind /proc $userDir/proc



#### Installation de logiciels dans le chroot ####
#### Lancer inChroot.bash dans le chroot en root #######################
cp inChroot.bash $userDir
chroot $userDir /bin/bash inChroot.bash $username $password $port $(id -u $username) $(id -g $username)



# Restart SSh service (Apply config)
/etc/init.d/ssh restart
