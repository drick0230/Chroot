#! /bin/bash
# Basic if statement

###########################################################################
# Script : ChrootSetup.ps1
#
# Description : Création d'un utilisateur avec son home en tant
#				que Chroot et installation de Bash.
#				
#
###########################################################################

# Constant Variables
installList=(/bin/bash /bin/apt-get /bin/tar /bin/curl /bin/gzip)

# Demander le nom de l'utilisateur
read -p "Nom d'utilisateur:" username
read -s -p "Mot de passe:" password

# Create user
sudo useradd $username

# Select Bash as Shell
sudo chsh -s $bashPath $username

# Password
echo -e $username:$password | sudo chpasswd

sudo userDir=/home/$username

# Créer son home
sudo mkdir $userDir



# Créer l'arboressence linux
sudo mkdir $userDir/dev
sudo mknod -m 666 $userDir/dev/null c 1 3
sudo mknod -m 666 $userDir/dev/tty c 5 0
sudo mknod -m 666 $userDir/dev/zero c 1 5
sudo mknod -m 666 $userDir/dev/random c 1 8

sudo mkdir $userDir/bin
sudo mkdir $userDir/etc
sudo cp -v -r --parents /usr/bin/env $userDir 

# Installer Bash
for installPath in "${installList[@]}";
do
	sudo cp -v -r --parents $installPath $userDir # Copy the binary version of Bash

	list="$(ldd $installPath | grep "=> /" | awk '{print $3}')" # List of dependencies
	for i in $list; do sudo cp --parents "$i" "${userDir}"; done # Copy dependencies into chrood

done



# Prise en charge des touches spéciaux dans Bash
sudo cp -r --parents "/etc/terminfo" "${userDir}"
sudo cp -r --parents "/lib/terminfo" "${userDir}"
sudo cp -r --parents "/usr/share/terminfo" "${userDir}"


# Installer SteamCMD
sudo apt install steamcmd
sudo add-apt-repository multiverse
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install lib32gcc1 steamcmd 
sudo cp -v -r --parents /usr/bin/env $userDir # Copy the binary version

# Add internet access
sudo cp -r --parents /etc/resolv.conf $userDir

# Configurer SSH
# Users info into the chrood
sudo cp -vf /etc/{passwd,group} $userDir/etc

# Add users to sshd_config
echo -e '\n' | sudo tee -a /etc/ssh/sshd_config > /dev/null
echo -e "Match User ${username}" | sudo tee -a /etc/ssh/sshd_config > /dev/null
echo -e "\tChrootDirectory ${userDir}" | sudo tee -a /etc/ssh/sshd_config > /dev/null

# Give all right in chroot to user
sudo chown -R $user:$user $userDir

# Permission du home à Root
sudo chown root:root $userDir
sudo chmod 0755 $userDir

# Restart SSH service (Apply config)
sudo /etc/init.d/ssh restart