username=$1
password=$2

# Create user
useradd $username

# Password
echo -e $username:$password | sudo chpasswd

# Donner les droits sudo à l'utilisateur
usermod -a -G sudo $username
echo "username  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$username > /dev/null

# Installer Steam
useradd -m steam
cd /home/steam
apt-get install software-properties-common
add-apt-repository multiverse
dpkg --add-architecture i386
apt update
apt install lib32gcc1 steamcmd