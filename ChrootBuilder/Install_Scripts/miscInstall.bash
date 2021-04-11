#! /bin/bash
# Basic if statement

###########################################################################
# Script : miscInstall.bash
#
# Description : Installation de dépendances globales.
#
###########################################################################

apt-get update

apt-get -y install software-properties-common
add-apt-repository multiverse

apt-get update