#!/bin/bash

sudo apt-get update
sudo apt-get upgrade -y
git clone https://github.com/katamb/debian-cis.git
cd debian-cis
sudo cp debian/default /etc/default/cis-hardening
sudo sed -i "s#CIS_ROOT_DIR=.*#CIS_ROOT_DIR='$(pwd)'#" /etc/default/cis-hardening
sudo ./bin/hardening.sh --audit --allow-unsupported-distribution
sudo ./bin/hardening.sh --apply --set-hardening-level 2 --allow-unsupported-distribution
sudo ./bin/hardening.sh --apply --allow-unsupported-distribution
sudo ./../custom_scripts/1.1.1.x_unused_filesystems.sh
sudo ./../custom_scripts/1.1.23_disable_usb_storage.sh
sudo ./../custom_scripts/3.4.x_unused_services.sh
sudo ./../custom_scripts/5.1.2_crontab_permissions.sh

# Audit
sudo ./bin/hardening.sh --audit --allow-unsupported-distribution
