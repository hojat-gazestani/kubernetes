
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

## Disable swap & add kernel settings
```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

```bash
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
```

```bash
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF 

sudo sysctl --system
```

## Install containerd run time
```bash
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt update -y
sudo apt install -y containerd.io

containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd
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
kubeadm config images pull
# Create a snapshot
sudo kubeadm init  --apiserver-advertise-address=192.168.56.10 --pod-network-cidr 192.168.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# OR
export KUBECONFIG=/etc/kubernetes/admin.conf

 kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
sudo kubectl apply -f calico.yaml
sudo systemctl status kubelet -l

```

```bash
kubeadm token create --print-join-command
kubeadm join 192.168.56.10:6443 --token hsgmo9.ogxzyianiogtxceq \
	--discovery-token-ca-cert-hash sha256:c53f1aaa3035bb4f122aa6792b607bcc4bf4764c3fd98d3e903d9ab318b110dd

kubectl get pods -n kube-system
```

## Test Kubernetes Installation
```bash
kubectl create deployment nginx-app --image=nginx --replicas=2

# Check the status of nginx-app deployment
kubectl get deployment nginx-app

# Expose the deployment as NodePort,
kubectl expose deployment nginx-app --type=NodePort --port=80

# Run following commands to view service status
kubectl get svc nginx-app
kubectl describe svc nginx-app
```

## pod
```bash
kgp myapp1 -o wide
NAME     READY   STATUS    RESTARTS   AGE   IP               NODE      NOMINATED NODE   READINESS GATES
myapp1   1/1     Running   0          14h   192.168.189.83   worker2   <none>           <none>
user@master:~$ kgsrv
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   4d23h
```

```bash
kubectl run nginx-pod --image=nginx
k exec -it myapp1 -- sh
echo Arman > /usr/share/nginx/html/index.html
# cat /usr/share/nginx/html/index.html

```

```bash
# Schedule a Kubernetes deployment using a container from Google samples
kubectl create deployment hello-world --image=gcr.io/google-samples/hello-app:1.0

# View all kubernets deployment
kubectl get deployments

# Get pod info
kubectl get pods -o wide

# Scale up the replica set to 4
kubectl scale --replicas=4 deployment/hello-world

# Get pod info
kubectl get pods -o wide

# Run the service
curl http://<POD-IP>:8080
```

## VXLAN kubernetes
```bash
sudo apt update -y
sudo apt upgrade -y

sudo apt install containerd -y

sudo mkdir -p /etc/containerd
sudo su -
exit

curl -s https://packages.cloud.google.com/apt/doc/apt-gkey.gpt | sudo apt-key add
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

sudo apt install kubeadm kubelet kubectl -y

sudo vim /etc/sysctl.conf
net.bridge.bridge-nf-call-iptables = 1

sudo -s

sudo echo '1' > /proc/sys/net/ipv4/ip_forward
exit

sudo sysctl --system

sudo modeprobe overlay
sudo modeprobe br_netfilter

sudo vim /etc/fstab
# comment out "/swap.img"

sudo swapoff -a

sudo kubeadm config images pull

curl https://docs.projectcalico.org/manifests/calico.yaml > calico.yaml

# Modify the "Calico.yaml" file
	# 1. calico_tackend: "vxlan"
	# 2. Comment out "- -brid-live"
	# 3. Comment out "- -bird-ready"
	# 4. 	- name: CALICO_IPV4POOL_VXLAN # CALICO_IPV4POOL_IPIP
						value: "Always"
	# 5.		- name: CALICO_IPV4POOL_IPIP #Learning Channel
						value: "Never"
						
scp -r calico.yaml user@MASTER

kubectl apply -f ./calico.yaml

# Copy the ./kube folder to other nodes
scp -r $HOME/.kube user@$NODE1:/home/user
```



## Cluster info and tests
```bash
kubectl get nodes -o wide

# Optionaly untaint master so that PODs can be scheuled on master
kubectl taint node kube-master node-role.kubernetes.io/master-

ip link show type vxlan

ip addr | show type vxlan

ip addr | grep vxlan.calico

kubectl create deployment hello-world --iamge=gcr.io/google-samples/hello-app:1.0

kubectl scale --replicas=2 deployment/hello-world

kubectl get pods -o wide

POD_IP_ON_NODE1=$(kubectl get pods -o wide  | grep kube-node1 | awk '{ print &6}')
echo $POD_IP_ON_NODE1

curl http://$POD_IP_ON_NODE1:8080
```