# # Compartment
# resource "oci_identity_compartment" "tf-compartment" {
#   compartment_id = var.tenancy_ocid
#   description    = "Compartment for market Terraform resources."
#   name           = var.compartment_name
# }

# # Security List
# # resource "oci_core_security_list" "public-security-list" {
# #   compartment_id = oci_identity_compartment.tf-compartment.id
# #   vcn_id         = oci_core_vcn.market_vcn.id
# #   display_name   = "${var.prefix}-security-list"

# #   egress_security_rules {
# #     stateless        = false
# #     destination      = "0.0.0.0/0"
# #     destination_type = "CIDR_BLOCK"
# #     protocol         = "all"
# #   }

# #   ingress_security_rules {
# #     stateless   = false
# #     source      = "10.0.0.0/16"
# #     source_type = "CIDR_BLOCK"
# #     protocol    = "6"
# #     tcp_options {
# #       min = 22
# #       max = 22
# #     }
# #   }
# #   ingress_security_rules {
# #     stateless   = false
# #     source      = "0.0.0.0/0"
# #     source_type = "CIDR_BLOCK"
# #     protocol    = "1"
# #     icmp_options {
# #       type = 3
# #       code = 4
# #     }
# #   }

# #   ingress_security_rules {
# #     stateless   = false
# #     source      = "10.0.0.0/16"
# #     source_type = "CIDR_BLOCK"
# #     protocol    = "6"
# #     tcp_options {
# #       min = 6443
# #       max = 6443
# #     }
# #   }

# #   ingress_security_rules {
# #     stateless   = false
# #     source      = "10.0.0.0/16"
# #     source_type = "CIDR_BLOCK"
# #     protocol    = "6"
# #     tcp_options {
# #       min = 10250
# #       max = 10252
# #     }
# #   }

# #   ingress_security_rules {
# #     stateless   = false
# #     source      = "10.0.0.0/16"
# #     source_type = "CIDR_BLOCK"
# #     protocol    = "6"
# #     tcp_options {
# #       min = 2049
# #       max = 2049
# #     }
# #   }

# #   ingress_security_rules {
# #     stateless   = false
# #     source      = "10.0.0.0/16"
# #     source_type = "CIDR_BLOCK"
# #     protocol    = "6"
# #     tcp_options {
# #       min = 111
# #       max = 111
# #     }
# #   }

# #   ingress_security_rules {
# #     stateless   = false
# #     source      = "10.0.0.0/16"
# #     source_type = "CIDR_BLOCK"
# #     protocol    = "6"
# #     tcp_options {
# #       min = 20048
# #       max = 20048
# #     }
# #   }

# #   ingress_security_rules {
# #     stateless   = false
# #     source      = "0.0.0.0/0"
# #     source_type = "CIDR_BLOCK"
# #     protocol    = "6"
# #     tcp_options {
# #       min = 6443
# #       max = 6443
# #     }
# #   }

# #   ingress_security_rules {
# #     stateless   = false
# #     source      = "10.0.0.0/16"
# #     source_type = "CIDR_BLOCK"
# #     protocol    = "6"
# #     tcp_options {
# #       min = 5473
# #       max = 5473
# #     }
# #   }

# #   ingress_security_rules {
# #     stateless   = false
# #     source      = "10.0.0.0/16"
# #     source_type = "CIDR_BLOCK"
# #     protocol    = "6"
# #     tcp_options {
# #       min = 179
# #       max = 179
# #     }
# #   }

# #   ingress_security_rules {
# #     stateless   = false
# #     source      = "10.0.0.0/16"
# #     source_type = "CIDR_BLOCK"
# #     protocol    = "6"
# #     tcp_options {
# #       min = 8443
# #       max = 8443
# #     }
# #   }

# #   ingress_security_rules {
# #     stateless   = false
# #     source      = "10.0.0.0/24"
# #     source_type = "CIDR_BLOCK"
# #     protocol    = "6"
# #     tcp_options {
# #       min = 30001
# #       max = 30001
# #     }
# #   }

# #   ingress_security_rules {
# #     stateless   = false
# #     source      = "10.0.0.0/16"
# #     source_type = "CIDR_BLOCK"
# #     protocol    = "17"
# #     udp_options {
# #       min = 4789
# #       max = 4789
# #     }
# #   }

# #   ingress_security_rules {
# #     stateless   = false
# #     source      = "10.0.0.0/16"
# #     source_type = "CIDR_BLOCK"
# #     protocol    = "17"
# #     udp_options {
# #       min = 51820
# #       max = 51820
# #     }
# #   }
# # }

# # # Internet Gateway
# # resource "oci_core_internet_gateway" "market_internet_gateway" {
# #   compartment_id = oci_identity_compartment.tf-compartment.id
# #   vcn_id         = oci_core_vcn.market_vcn.id
# #   display_name   = "${var.prefix}-internet-gateway"
# #   enabled        = true
# # }

# # # Route Table
# # resource "oci_core_route_table" "market_route_table" {
# #   #Required
# #   compartment_id = oci_identity_compartment.tf-compartment.id
# #   vcn_id         = oci_core_vcn.market_vcn.id

# #   display_name = "${var.prefix}-route-table"
# #   route_rules {
# #     #Required
# #     network_entity_id = oci_core_internet_gateway.market_internet_gateway.id
# #     description       = "Allow routing between VCN and Internet Gateway"
# #     destination       = "0.0.0.0/0"
# #     destination_type  = "CIDR_BLOCK"
# #   }
# # }

# # # VCN
# # resource "oci_core_vcn" "market_vcn" {
# #   #Required
# #   compartment_id = oci_identity_compartment.tf-compartment.id
# #   cidr_block     = "10.0.0.0/16"
# #   display_name   = "${var.prefix}-vcn"
# #   dns_label      = "${var.prefix}vcn"
# # }

# # # Subnet
# # resource "oci_core_subnet" "vcn-public-subnet" {
# #   compartment_id = oci_identity_compartment.tf-compartment.id
# #   vcn_id         = oci_core_vcn.market_vcn.id
# #   cidr_block     = "10.0.0.0/24"
# #   # Optional
# #   route_table_id    = oci_core_route_table.market_route_table.id
# #   security_list_ids = [oci_core_security_list.public-security-list.id]
# #   display_name      = "${var.prefix}-public-subnet"
# # }

# # ARM VM 1
# # resource "oci_core_instance" "arm_instance_1" {
# #   availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
# #   compartment_id      = oci_identity_compartment.tf-compartment.id
# #   shape               = "VM.Standard.A1.Flex"
# #   source_details {
# #     source_id   = data.oci_core_images.arm_os_image.images[0].id
# #     source_type = "image"
# #   }
# #   # Optional
# #   display_name = "${var.prefix}-arm-1"
# #   shape_config {
# #     ocpus         = 2
# #     memory_in_gbs = 12
# #   }
# #   create_vnic_details {
# #     assign_public_ip = true
# #     subnet_id        = oci_core_subnet.vcn-public-subnet.id
# #     private_ip       = "10.0.0.101"
# #   }
# #   metadata = {
# #     ssh_authorized_keys = tls_private_key.ssh_key.public_key_openssh
# #     user_data           = filebase64(var.k8s_cp_script)
# #   }
# #   preserve_boot_volume = false
# # }

# # # ARM VM 2
# # resource "oci_core_instance" "arm_instance_2" {
# #     availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
# #     compartment_id = oci_identity_compartment.tf-compartment.id
# #     shape = "VM.Standard.A1.Flex"
# #     source_details {
# #         source_id = data.oci_core_images.arm_os_image.images[0].id
# #         source_type = "image"
# #     }
# #     # Optional
# #     display_name = "${var.prefix}-arm-2"
# #     shape_config {
# #         ocpus = 2
# #         memory_in_gbs = 12
# #     }
# #     create_vnic_details {
# #         assign_public_ip = true
# #         subnet_id = oci_core_subnet.vcn-public-subnet.id
# #         private_ip = "10.0.0.102"
# #     }
# #     metadata = {
# #         ssh_authorized_keys = tls_private_key.ssh_key.public_key_openssh
# #         user_data = filebase64(var.k8s_dp_script)
# #     } 
# #     preserve_boot_volume = false
# # }

# # # AMD VM 1
# # resource "oci_core_instance" "amd_instance_1" {
# #     availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
# #     compartment_id = oci_identity_compartment.tf-compartment.id
# #     shape = "VM.Standard.E2.1.Micro"
# #     source_details {
# #         source_id = data.oci_core_images.amd_os_image.images[0].id
# #         source_type = "image"
# #     }
# #     # Optional
# #     display_name = "${var.prefix}-amd-1"
# #     shape_config {
# #         ocpus = 1
# #         memory_in_gbs = 1
# #     }
# #     create_vnic_details {
# #         assign_public_ip = true
# #         subnet_id = oci_core_subnet.vcn-public-subnet.id
# #         private_ip = "10.0.0.111"
# #     }
# #     metadata = {
# #         ssh_authorized_keys = tls_private_key.ssh_key.public_key_openssh
# #         user_data = filebase64(var.k8s_dp_script)
# #     } 
# #     preserve_boot_volume = false
# # }

# # # AMD VM 2
# # resource "oci_core_instance" "amd_instance_2" {
# #     availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
# #     compartment_id = oci_identity_compartment.tf-compartment.id
# #     shape = "VM.Standard.E2.1.Micro"
# #     source_details {
# #         source_id = data.oci_core_images.amd_os_image.images[0].id
# #         source_type = "image"
# #     }
# #     # Optional
# #     display_name = "${var.prefix}-amd-2"
# #     shape_config {
# #         ocpus = 1
# #         memory_in_gbs = 1
# #     }
# #     create_vnic_details {
# #         assign_public_ip = true
# #         subnet_id = oci_core_subnet.vcn-public-subnet.id
# #         private_ip = "10.0.0.112"
# #     }
# #     metadata = {
# #         ssh_authorized_keys = tls_private_key.ssh_key.public_key_openssh
# #         user_data = filebase64(var.k8s_dp_script)
# #     } 
# #     preserve_boot_volume = false
# # }

# module "k8s" {
#   source = "./modules/k8s/"

#   prefix              = var.prefix
#   compartment_id      = oci_identity_compartment.tf-compartment.id
#   availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
#   vcn_cidr_block      = "10.0.0.0/16"
#   subnet_cidr_block   = "10.0.0.0/24"
#   cp_config = {
#       shape = "VM.Standard.A1.Flex"
#       os_image = "Oracle-Linux-9.4-aarch64-2024.09.30-0"
#       ocpus = 2
#       memory_in_gbs = 12
#       private_ip = "10.0.0.101"
#   }
#   worker_config = [
#     {
#       shape         = "VM.Standard.A1.Flex"
#       os_image      = "Oracle-Linux-9.4-aarch64-2024.09.30-0"
#       ocpus         = 2
#       memory_in_gbs = 12
#       private_ip    = "10.0.0.102"
#     },
#     {
#       shape         = "VM.Standard.E2.1.Micro"
#       os_image      = "Oracle-Linux-9.4-Minimal-2024.07.29-0"
#       ocpus         = 1
#       memory_in_gbs = 1
#       private_ip    = "10.0.0.103"
#     },
#     {
#       shape         = "VM.Standard.E2.1.Micro"
#       os_image      = "Oracle-Linux-9.4-Minimal-2024.07.29-0"
#       ocpus         = 1
#       memory_in_gbs = 1
#       private_ip    = "10.0.0.104"
#     }
#   ]
#   nlb_private_ip = "10.0.0.100"
#   nlb_public_port = 80

# }
