region           = "ap-mumbai-1"
compartment_name = "tf-compartment-market"
prefix           = "market"
k8s_cp_script    = "./scripts/k8s/oracle-linux/cp-vm-bootstrap.sh"
k8s_dp_script    = "./scripts/k8s/oracle-linux/dp-vm-bootstrap.sh"
arm_os_image     = "Oracle-Linux-9.4-aarch64-2024.09.30-0"
amd_os_image     = "Oracle-Linux-9.4-Minimal-2024.07.29-0"