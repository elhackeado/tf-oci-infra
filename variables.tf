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