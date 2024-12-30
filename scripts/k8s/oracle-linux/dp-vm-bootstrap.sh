#!/bin/sh
echo "This is custom bootstrap script"
sudo dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo groupadd docker
sudo usermod -aG docker opc
sudo rm /etc/containerd/config.toml
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd

# Install kubelet, kubeadm, and kubectl
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo swapoff -a
sudo systemctl enable --now kubelet

# only for Control Plane
# sudo firewall-cmd --zone=public --permanent --add-port=6443/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10250/tcp       # kubelet api
sudo firewall-cmd --zone=public --permanent --add-port=30000-32767/tcp # NodePort
sudo firewall-cmd --zone=public --add-port=5473/tcp --permanent # calico Typha agent hosts
sudo firewall-cmd --zone=public --add-port=179/tcp --permanent # calico Calico networking (BGP)
sudo firewall-cmd --zone=public --add-port=4789/udp --permanent # Calico networking with VXLAN enabled
sudo firewall-cmd --zone=public --add-port=51820/udp --permanent # Calico networking with IPv4 Wireguard enabled
sudo firewall-cmd --reload

# sudo kubeadm init
# mkdir -p /home/opc/.kube
# sudo cp -i /etc/kubernetes/admin.conf /home/opc/.kube/config
# sudo chown opc:opc /home/opc/.kube/config
# kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/tigera-operator.yaml


echo "Waiting for the control plane to be ready..."
until curl -sk https://10.0.0.101:6443/readyz | grep "ok" > /dev/null; do echo "Waiting for control plane..."; sleep 5; done

echo "waiting for the NFS share to be available"
until showmount -e 10.0.0.101 | grep -oP '/nfs_share 10.0.0.0/24' > /dev/null; do echo "Waiting for NFS share..."; sleep 5; done

echo "Creating mount point for NFS share..."
sudo mkdir -p /nfs_share

echo "Mounting NFS share from 10.0.0.101:/nfs_share to /nfs_share..."
sudo mount 10.0.0.101:/nfs_share /nfs_share

echo "Verifying NFS mount..."
df -h | grep /nfs_share
# Auto-mount NFS share on boot by adding to /etc/fstab
echo "Adding entry to /etc/fstab for auto-mount..."
echo "10.0.0.101:/nfs_share /nfs_share nfs defaults 0 0" | sudo tee -a /etc/fstab

# Test the share by creating a test file
echo "Testing NFS share by creating a test file..."
echo "Hello, NFS!" | sudo tee /nfs_share/test_file.txt

# Verify the test file creation
echo "Contents of the test file:"
cat /nfs_share/test_file.txt
echo "NFS Client setup complete."

echo "waiting for the kubejoin file to be available"
until cat /nfs_share/kubeadm-join-command | grep "kubeadm join" > /dev/null; do echo "Waiting for kubejoin file..."; sleep 5; done
cat /nfs_share/kubeadm-join-command | sudo bash
