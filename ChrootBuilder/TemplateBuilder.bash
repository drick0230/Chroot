#! /bin/bash
# Basic if statement

###########################################################################
# Script : TemplateBuilder.bash
#
# Description : Création et configuration d'un template de chroot.
#				Programmes préinstallés:
#					-xfce
#
#
# Dépendances : schroot et debootstrap
#
###########################################################################

# Constant Variables
chrootTemplateDir="/srv/chrootTemplate"
bashInstall=('miscInstall.bash' 'xfceInstall.bash')

# Créer son chroot
umount $chrootTemplateDir/etc/resolv.conf
umount $chrootTemplateDir/proc
rm -r $chrootTemplateDir
mkdir $chrootTemplateDir

#### Installer Ubuntu dans le chroot (schroot) ####
debootstrap --arch=amd64 focal $chrootTemplateDir http://archive.ubuntu.com/ubuntu/

# Add internet access
cp --parents /run/systemd/resolve/stub-resolv.conf $chrootTemplateDir
cp --parents /etc/resolv.conf $chrootTemplateDir

# Add process management
mkdir $chrootTemplateDir/proc
mount -o bind /proc $chrootTemplateDir/proc

#### Installer xfce dans le chroot en root #######################
for path in "${bashInstall[@]}";
do
	cp -v $path $chrootTemplateDir
	chroot $chrootTemplateDir /bin/bash $path
done

# Remove process management (Need to be mounted later, not copied)
umount $chrootTemplateDir/proc

