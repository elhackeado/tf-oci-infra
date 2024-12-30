variable "tenancy_ocid" {
  description = "The OCID of the tenancy."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "The region to create the resources in."
  type        = string
}

variable "compartment_name" {
  description = "The name of the compartment to create the OCI resources in."
  type        = string
}

variable "prefix" {
  description = "The prefix to use for the resource names."
  type        = string
}

variable "k8s_cp_script" {
  description = "The path to the k8s control plane bootstrap script."
  type        = string
}

variable "k8s_dp_script" {
  description = "The path to the k8s data plane bootstrap script."
  type        = string
}

variable "arm_os_image" {
  description = "display name of the ARM OS image"
  type        = string
}

variable "amd_os_image" {
  description = "display name of the AMD OS image"
  type        = string
}

# User Credentials
variable "user_ocid" {
  description = "The OCID of the terraform user."
  type        = string
  sensitive   = true
}

variable "private_key_path" {
  description = "path to the private key file."
  type        = string
}

variable "fingerprint" {
  description = "The fingerprint of the public key."
  type        = string
  sensitive   = true
}