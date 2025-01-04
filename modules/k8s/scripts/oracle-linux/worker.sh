#!/bin/sh
sudo systemctl disable --now firewalld
# Create Swap memory
sudo dd if=/dev/zero of=/swapfile1 bs=1024 count=8388608 # 8GB
sudo chown root:root /swapfile1
sudo chmod 0600 /swapfile1
sudo mkswap /swapfile1
sudo swapon /swapfile1
echo '/swapfile1 none swap sw 0 0' | sudo tee -a /etc/fstab
echo '(allow iptables_t cgroup_t (dir (ioctl)))' | sudo tee /root/local_iptables.cil
sudo semodule -i /root/local_iptables.cil
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
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
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
# modprobe overlay
# modprobe br_netfilter
sudo sysctl --system
sudo yum install yum-utils -y
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install containerd.io -y
CONTAINDERD_CONFIG_PATH=/etc/containerd/config.toml
sudo rm "${CONTAINDERD_CONFIG_PATH}"
containerd config default | sudo tee "${CONTAINDERD_CONFIG_PATH}"
sudo sed -i "s/SystemdCgroup = false/SystemdCgroup = true/g"  "${CONTAINDERD_CONFIG_PATH}"
sudo systemctl enable --now containerd
sudo systemctl restart containerd

# Disable swap
sudo swapoff -a
sudo rm -rf /.swapfile
sudo sed -i '/swapfile/d' /etc/fstab

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
