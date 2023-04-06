
## Before you begin
- 2 GB or more of RAM per machine
- 2 CPUs or more.
- Full network connectivity between all machines in the cluster
- Unique hostname, MAC address, and product_uuid for every node
```bash
ip link
ifconfig -a
sudo cat /sys/class/dmi/id/product_uuid
```
- Certain ports are open on your machines. 
````bash
 nc 127.0.0.1 6443
````
- Swap disabled.
```bash
sudo swapoff -a
sudo vim /etc/fstab
# UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx none            swap    sw
``` 
## Container Runtimes

### Install Docker Engine
- source https://docs.docker.com/engine/install/ubuntu/
- 
![Installation source ](https://docs.docker.com/engine/install/ubuntu/)

A[Installation source ](https://docs.docker.com/engine/install/ubuntu/)
```bash
sudo apt-get update -y

sudo apt-get install \
    ca-certificates \
    curl \
    gnupg
    
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
sudo apt-get update -y

sudo chmod a+r /etc/apt/keyrings/docker.gpg
sudo apt-get update -y

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo docker run hello-world
```

## Install and configure prerequisites

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

lsmod | grep br_netfilter
lsmod | grep overlay

sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward
```

## Initializing your control-plane node

- Error
-  container runtime is not running:  validate service connection
```bash
sudo apt remove containerd
sudo apt update -y
sudo apt install containerd.io -y
sudo rm /etc/containerd/config.toml
sudo systemctl restart containerd
```

```bash
sudo kubeadm init  --apiserver-advertise-address=192.168.56.10 --pod-network-cidr 172.18.1.0/24

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# OR
export KUBECONFIG=/etc/kubernetes/admin.conf

sudo kubectl apply -f calico.yaml
sudo systemctl status kubelet -l
```