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

# Instal kubelet, kubeadm, and kubectl
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
sudo firewall-cmd --zone=public --permanent --add-port=6443/tcp    # kube-api-server
sudo firewall-cmd --zone=public --permanent --add-port=10250/tcp   # kubelet api
sudo firewall-cmd --zone=public --permanent --add-port=10251/tcp   # kube-scheduler
sudo firewall-cmd --zone=public --permanent --add-port=10252/tcp   # kube-controller-manager
sudo firewall-cmd --zone=public --permanent --add-port=2379/tcp    # etcd
sudo firewall-cmd --zone=public --permanent --add-port=2380/tcp    # etcd
sudo firewall-cmd --reload
# Get IPs for the machine
PRIVATE_IP=$(curl -s -H "Authorization: Bearer Oracle" http://169.254.169.254/opc/v2/vnics/0/privateIp)
PUBLIC_IP=$(curl ifconfig.me)
sudo kubeadm init --apiserver-advertise-address $PRIVATE_IP \
                  --pod-network-cidr=192.168.0.0/16 \
                  --control-plane-endpoint $PRIVATE_IP \
                  --node-name $HOSTNAME \
                  --apiserver-cert-extra-sans=$PUBLIC_IP,$PRIVATE_IP,10.96.0.1 \
                  --ignore-preflight-errors=all
mkdir -p /home/opc/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/opc/.kube/config
sudo chown opc:opc /home/opc/.kube/config
# kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/tigera-operator.yaml --kubeconfig=/etc/kubernetes/admin.conf
# # kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/custom-resources.yaml --kubeconfig=/etc/kubernetes/admin.conf
# kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f - <<EOF
# # This section includes base Calico installation configuration.
# # For more information, see: https://docs.tigera.io/calico/latest/reference/installation/api#operator.tigera.io/v1.Installation
# apiVersion: operator.tigera.io/v1
# kind: Installation
# metadata:
#   name: default
# spec:
#   # Configures Calico networking.
#   calicoNetwork:
#     ipPools:
#     - name: default-ipv4-ippool
#       blockSize: 26
#       cidr: 192.168.0.0/16
#       encapsulation: VXLANCrossSubnet
#       natOutgoing: Enabled
#       nodeSelector: all()
#     nodeAddressAutodetectionV4:
#       kubernetes: NodeInternalIP

# ---

# # This section configures the Calico API server.
# # For more information, see: https://docs.tigera.io/calico/latest/reference/installation/api#operator.tigera.io/v1.APIServer
# apiVersion: operator.tigera.io/v1
# kind: APIServer
# metadata:
#   name: default
# spec: {}
# EOF
# kubectl taint nodes --all node-role.kubernetes.io/control-plane- --kubeconfig=/etc/kubernetes/admin.conf

# Share kubejoin command with worker nodes
sudo mkdir /nfs_share
sudo chmod 777 /nfs_share
echo "/nfs_share 10.0.0.0/24(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
sudo exportfs -a
sudo systemctl start nfs-server
sudo systemctl enable nfs-server
sudo systemctl start rpcbind
sudo systemctl enable rpcbind
sudo firewall-cmd --zone=public --add-service=nfs --permanent
sudo firewall-cmd --zone=public --add-service=rpc-bind --permanent
sudo firewall-cmd --zone=public --add-port=2049/tcp --permanent  # NFS
sudo firewall-cmd --zone=public --add-port=111/tcp --permanent   # Portmapper (RPC)
sudo firewall-cmd --zone=public --add-port=20048/tcp --permanent  # mountd
sudo firewall-cmd --zone=public --add-port=5473/tcp --permanent # calico Typha agent hosts
sudo firewall-cmd --zone=public --add-port=179/tcp --permanent # calico Calico networking (BGP)
sudo firewall-cmd --zone=public --add-port=4789/udp --permanent # Calico networking with VXLAN enabled
sudo firewall-cmd --zone=public --add-port=51820/udp --permanent # Calico networking with IPv4 Wireguard enabled
sudo firewall-cmd --reload
sudo exportfs -v
kubeadm token create --print-join-command | tee /nfs_share/kubeadm-join-command

