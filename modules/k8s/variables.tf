variable "prefix" {
  description = "The prefix to use for the resource names."
  type        = string
}

variable "compartment_id" {
  description = "The OCID of the compartment to create the resources in."
  type        = string
}

variable "availability_domain" {
  description = "The availability domain to create the resources in."
  type        = string
}

### VCN ###
variable "vcn_cidr_block" {
    description = "The CIDR block to use for the VCN."
    type        = string
    default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
    description = "The CIDR block to use for the subnet."
    type        = string
    default     = "10.0.0.0/24"
}
#-- END VCN --#

variable "cp_config" {
  description = "The config of the control plane nodes."
  type = object({
    shape         = string
    os_image      = string
    ocpus         = number
    memory_in_gbs = number
    private_ip    = string
  })

  default = {
    shape         = "VM.Standard.A1.Flex"
    os_image      = "Oracle-Linux-9.4-aarch64-2024.09.30-0"
    ocpus         = 2
    memory_in_gbs = 12
    private_ip    = "10.0.0.101"
  }
}

variable "worker_config" {
  description = "The config of the worker nodes."
  type = list(object({
    shape         = string
    os_image      = string
    ocpus         = number
    memory_in_gbs = number
    private_ip    = string
  }))
  default = [
    {
      shape         = "VM.Standard.A1.Flex"
      os_image      = "Oracle-Linux-9.4-aarch64-2024.09.30-0"
      ocpus         = 2
      memory_in_gbs = 12
      private_ip    = "10.0.0.102"
    },
    {
      shape         = "VM.Standard.E2.1.Micro"
      os_image      = "Oracle-Linux-9.4-Minimal-2024.07.29-0"
      ocpus         = 1
      memory_in_gbs = 1
      private_ip    = "10.0.0.103"
    },
    {
      shape         = "VM.Standard.E2.1.Micro"
      os_image      = "Oracle-Linux-9.4-Minimal-2024.07.29-0"
      ocpus         = 1
      memory_in_gbs = 1
      private_ip    = "10.0.0.104"
    }
  ]
}

variable "k8s_controlplane_script" {
  description = "The path to the k8s control plane bootstrap script."
  type        = string
  default     = "scripts/oracle-linux/controlplane.sh"
}

variable "k8s_worker_script" {
  description = "The path to the k8s worker bootstrap script."
  type        = string
  default     = "scripts/oracle-linux/worker.sh"
}

## NLB ##

variable "nlb_private_ip" {
    description = "The private IP address to assign to the NLB."
    type        = string
    default     = "10.0.0.100"
}

variable "nlb_public_port" {
    description = "The public port to use for the NLB."
    type        = number
    default     = 80
}