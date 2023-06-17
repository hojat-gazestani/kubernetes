#!/bin/bash

sudo hostnamectl set-hostname master

echo "alias ipa='ip -c -br a'
alias ipr='ip -c -br r'
" >> ~/.bashrc

sudo sed -i 's/192.168.56.5/192.168.56.50/g' /etc/netplan/00-installer-config.yaml
sudo netplan apply
