#!/bin/bash

# Check Root Privilege
if [ "$EUID" -ne 0 ]
  then echo "Root privilege is required to run the installation script."
  exit
fi

# Set Hostname
hostnamectl set-hostname ggez-hosting
sed -i "s/127.0.1.1/127.0.1.1 ggez-hosting/" /etc/hosts

# Configure APT repository
cp -rf env/etc/apt/sources.list /etc/apt/sources.list
apt update

# Install Packages (Nginx, PHP-FPM)
apt install -y nginx php-fpm php-mbstring php-xmlrpc php-soap php-gd php-xml php-intl php-mysql php-cli php-ldap php-zip php-curl

# Create Users
useradd -m -d /home/grizz grizz
useradd -m -d /home/icebear icebear
useradd -m -d /home/panda panda

# Add sudo user
usermod -aG sudo panda

# Copy files
cp -rf env/* /

# Configure sudoers
sed -i "s/#includedir \/etc\/sudoers.d/includedir \/etc\/sudoers.d" /etc/sudoers

# Configure Nginx
rm -f /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/server.conf /etc/nginx/sites-enabled/server.conf
ln -s /etc/nginx/sites-available/grizz.conf /etc/nginx/sites-enabled/grizz.conf 
ln -s /etc/nginx/sites-available/icebear.conf /etc/nginx/sites-enabled/icebear.conf
ln -s /etc/nginx/sites-available/panda.conf /etc/nginx/sites-enabled/panda.conf

# Restart services
systemctl restart php7.2-fpm
systemctl restart nginx

# Start service on boot
systemctl enable php7.2-fpm
systemctl enable nginx

# Remove default index.html
rm -f /var/www/html/index.nginx-debian.html

# Set owners and permission for public files
chown -R www-data. /var/www/html
chown -R grizz. /home/grizz
chown -R icebear. /home/icebear
chown -R panda. /home/panda
