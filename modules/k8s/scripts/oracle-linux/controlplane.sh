#!/bin/sh
sudo systemctl disable --now firewalld
sudo swapoff -a
sudo rm -rf /.swapfile 
sudo sed -i '/swapfile/d' /etc/fstab
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

PRIVATE_IP=$(curl -s -H "Authorization: Bearer Oracle" http://169.254.169.254/opc/v2/vnics/0/privateIp)
PUBLIC_IP=$(curl ifconfig.me)
sudo kubeadm init --apiserver-advertise-address $PRIVATE_IP \
                  --pod-network-cidr=10.244.0.0/16 \
                  --service-cidr=10.96.0.0/12 \
                  --control-plane-endpoint $PRIVATE_IP \
                  --node-name $HOSTNAME \
                  --apiserver-cert-extra-sans=$PUBLIC_IP,$PRIVATE_IP,10.96.0.1 \
                  --ignore-preflight-errors=all
mkdir -p /home/opc/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/opc/.kube/config
sudo chown opc:opc /home/opc/.kube/config
# Share kubejoin command with worker nodes
sudo mkdir /nfs_share
sudo chmod 777 /nfs_share
echo "/nfs_share 10.0.0.0/24(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
sudo exportfs -a
sudo systemctl start nfs-server
sudo systemctl enable nfs-server
sudo systemctl start rpcbind
sudo systemctl enable rpcbind
sudo exportfs -v
kubeadm token create --print-join-command | tee /nfs_share/kubeadm-join-command

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/tigera-operator.yaml --kubeconfig=/etc/kubernetes/admin.conf
kubectl wait --for=condition=available deployment/tigera-operator -n tigera-operator --timeout=120s --kubeconfig=/etc/kubernetes/admin.conf
# # kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/custom-resources.yaml --kubeconfig=/etc/kubernetes/admin.conf
kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f - <<EOF
# This section includes base Calico installation configuration.
# For more information, see: https://docs.tigera.io/calico/latest/reference/installation/api#operator.tigera.io/v1.Installation
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  # Configures Calico networking.
  calicoNetwork:
    ipPools:
    - name: default-ipv4-ippool
      blockSize: 26
      cidr: 10.244.0.0/16
      encapsulation: IPIP
      natOutgoing: Enabled
      nodeSelector: all()

---

# This section configures the Calico API server.
# For more information, see: https://docs.tigera.io/calico/latest/reference/installation/api#operator.tigera.io/v1.APIServer
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}
EOF
# kubectl taint nodes --all node-role.kubernetes.io/control-plane- --kubeconfig=/etc/kubernetes/admin.conf
kubectl taint nodes --all node-role.kubernetes.io/master- --kubeconfig=/etc/kubernetes/admin.conf
kubectl taint nodes --all  node-role.kubernetes.io/control-plane- --kubeconfig=/etc/kubernetes/admin.conf
# Install flux controllers
kubectl apply -f https://github.com/fluxcd/flux2/releases/latest/download/install.yaml --kubeconfig=/etc/kubernetes/admin.conf
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0-beta.0/deploy/static/provider/baremetal/deploy.yaml --kubeconfig=/etc/kubernetes/admin.conf
# kubectl delete validatingwebhookconfiguration ingress-nginx-admission --kubeconfig=/etc/kubernetes/admin.conf
# kubectl patch svc ingress-nginx-controller -n ingress-nginx --patch '{"spec":{"ports":[{"port":80,"targetPort":80,"nodePort":30001,"protocol":"TCP"}]}}' --kubeconfig=/etc/kubernetes/admin.conf

# Deploy sample app
kubectl apply --kubeconfig=/etc/kubernetes/admin.conf -f - <<EOF
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: el-flux-fleet
  namespace: flux-system
spec:
  interval: 1m
  url: https://github.com/elhackeado/flux-fleet
  ref:
    branch: main
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: flux-apps
  namespace: flux-system
spec:
  interval: 1m
  targetNamespace: default
  sourceRef:
    kind: GitRepository
    name: el-flux-fleet
  path: "./base"
  prune: true
  timeout: 1m

EOF