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
bashPath=/bin/bash
aptGetPath=/bin/apt-get
aptGetPath2=/etc/apt/apt.conf.d/

# Demander le nom de l'utilisateur
read -p "Nom d'utilisateur:" username
read -s -p "Mot de passe:" password

userDir=/home/$username

# Create user
useradd $username

# Select Bash as Shell
chsh -s $bashPath $username

# Password
echo -e $username:$password | sudo chpasswd

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

# Installer Bash
sudo cp $bashPath $userDir/bin # Copy the binary version of Bash

list="$(ldd $bashPath | egrep -o '/lib.*\.[0-9]')" # List of dependencies
for i in $list; do sudo cp --parents "$i" "${userDir}"; done # Copy dependencies into chrood

# Prise en charge des touches spéciaux dans Bash
sudo cp -r --parents "/etc/terminfo" "${userDir}"
sudo cp -r --parents "/lib/terminfo" "${userDir}"
sudo cp -r --parents "/usr/share/terminfo" "${userDir}"

# Installer Apt-Get
sudo cp -v $aptGetPath $userDir/bin # Copy the binary version

list="$(ldd $aptGetPath | grep "=> /" | awk '{print $3}')" # List of dependencies
for i in $list; do sudo cp -v --parents "$i" "${userDir}"; done # Copy dependencies into chrood

sudo cp -v -r --parents $aptGetPath2 $userDir # Copy the binary version

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
