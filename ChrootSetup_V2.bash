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
shellPath='/bin/bash'
installList=('/bin/bash' '/bin/apt-get' '/bin/tar' '/bin/curl' '/bin/gzip')
cpList=('/etc/terminfo' '/lib/terminfo' '/usr/share/terminfo' '/etc/apt/apt.conf.d/')

# Demander le nom de l'utilisateur
read -p "Nom d'utilisateur:" username
read -s -p "Mot de passe:" password
echo -e '\n'

userDir=/home/$username

# Create user
useradd $username

# Password
echo -e $username:$password | sudo chpasswd

# Select Bash as Shell
sudo chsh -s $shellPath $username

# Créer son home
sudo mkdir $userDir

# Permission du home à Root
sudo chown root:root $userDir
sudo chmod 0755 $userDir

# Créer l'arboressence linux
sudo mkdir $userDir/dev
sudo mknod -m 666 $userDir/dev/null c 1 3
sudo mknod -m 666 $userDir/dev/tty c 5 0
sudo mknod -m 666 $userDir/dev/zero c 1 5
sudo mknod -m 666 $userDir/dev/random c 1 8

sudo mkdir $userDir/bin
sudo mkdir $userDir/etc

# Installer les logicielles depuis le système principal
for installPath in "${installList[@]}";
do
	sudo cp -v -r --parents $installPath $userDir # Copy the binary version of Bash

	list=($(ldd $installPath | tr ' ' '\n' | grep "/lib")) # List of dependencies
	for i in ${list[@]}; do sudo cp --parents "$i" "${userDir}"; done # Copy dependencies into chrood
done

# Copier depuis le système principal
for cpPath in "${cpList[@]}";do sudo cp -r --parents "$cpPath" "${userDir}"; done

# Configurer SSH
# Users info into the chrood
sudo cp -vf /etc/{passwd,group} $userDir/etc

# Add users to sshd_config
echo -e '\n' | sudo tee -a /etc/ssh/sshd_config > /dev/null
echo -e "Match User ${username}" | sudo tee -a /etc/ssh/sshd_config > /dev/null
echo -e "\tChrootDirectory ${userDir}" | sudo tee -a /etc/ssh/sshd_config > /dev/null

# Permission du home à Root
sudo chown root:root $userDir
sudo chmod 0755 $userDir

# Restart SSh service (Apply config)
sudo /etc/init.d/ssh restart
