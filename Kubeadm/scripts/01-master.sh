#!/bin/bash

sudo hostnamectl set-hostname master80

echo "alias ipa='ip -c -br a'
alias ipr='ip -c -br r'
" >> ~/.bashrc

sudo sed -i 's/192.168.56.10/192.168.56.80/g' /etc/netplan/00-installer-config.yaml
sudo netplan apply
