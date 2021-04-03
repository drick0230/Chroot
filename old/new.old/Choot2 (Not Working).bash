#! /bin/bash
# Basic if statement

###########################################################################
# Script : ChrootSetup.ps1
#
# Description : Création du home d'un utilisateur en tant
#				que Chroot et installation des logicielles de base.
#				L'utilisateur doit avoir préalablement été créer avec
#				adduser <username>
#				
#
###########################################################################

# Demander le nom de l'utilisateur

if [ $(id -u) -eq 0 ]; then
    read -p "Enter username : " username
    read -s -p "Enter password : " password
    egrep "^$username" /etc/passwd >/dev/null
    if [ $? -eq 0 ]; then
        echo "$username exists!"
        exit 1
    else
        pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
        useradd -m -p "$pass" "$username"
        [ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
		if [ $? -eq 0 ]; then
			userDir=/home/$username

			# Créer son home
			sudo mkdir userDir

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
			binPath=/bin/bash

			sudo cp -v $binPath $userDir/bin # Copy the binary version of Bash

			list="$(ldd $binPath | egrep -o '/lib.*\.[0-9]')" # List of dependencies
			for i in $list; do sudo cp -v --parents "$i" "${userDir}"; done # Copy dependencies into chrood

			# Prise en charge des touches spéciaux dans Bash
			sudo cp -v -r --parents "/etc/terminfo" "${userDir}"
			sudo cp -v -r --parents "/lib/terminfo" "${userDir}"
			sudo cp -v -r --parents "/usr/share/terminfo" "${userDir}"

			# Configurer SSH
			# Users info into the chrood
			sudo cp -vf /etc/{passwd,group} $userDir/etc

			# Add users to sshd_config
			echo -e '\n' | sudo tee -a /etc/ssh/sshd_config > /dev/null
			echo -e "Match User ${username}" | sudo tee -a /etc/ssh/sshd_config > /dev/null
			echo -e "\tChrootDirectory ${userDir}" | sudo tee -a /etc/ssh/sshd_config > /dev/null

			# Restart SSh service (Apply config)
			sudo /etc/init.d/ssh restart
		fi
    fi
else
    echo "Only root may add a user to the system."
    exit 2
fi
