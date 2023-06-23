#!/bin/bash

# Install required packages
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates lsb-release

# Add Docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo tee /etc/modules-load.d/containerd.conf << EOF
overlay
br_netfilter
EOF

# Install containerd
sudo apt update
sudo apt install -y containerd.io

# Configure containerd
sudo -i
mkdir -p /etc/containerd
containerd config default>/etc/containerd/config.toml

# restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd
systemctl status containerd