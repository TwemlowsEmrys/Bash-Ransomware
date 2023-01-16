#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "you must have root perms to run this script!"
    exit 1
fi

if ! [ -x "$(command -v gpg)" ]; then
    echo 'Error: gpg is not installed. Installing gpg...'
    apt-get update && apt-get install -y gnupg
    echo 'gpg has been installed'
else
    echo 'gpg is already installed'
fi

read -p "Enter the password for decryption: " password

echo "Decryption in progress..."

target_dir_1="/var/lib/docker/volumes"
target_dir_2="/var/lib/docker/containers"
target_dir_3="/home"
target_dir_4="/var/www"
target_dir_5="/home/backups"
target_dir_6="/var/backups"

for file in $(find $target_dir_1 $target_dir_2 $target_dir_3 $target_dir_4 $target_dir_5 $target_dir_6 -type f -name "*.Magnus"); do
    echo "$password" | gpg --batch --yes --passphrase-fd 0 --decrypt "$file"
    rm "$file"
    mv "${file%.Magnus}" "$file"
done

echo "Decryption has finished!"
