# Output the "list" of all availability domains.
output "all-availability-domains-in-your-tenancy" {
  value = data.oci_identity_availability_domains.ads.availability_domains
}

output "arm_os_image" {
  value = data.oci_core_images.arm_os_image.images[0].display_name
}

output "amd_os_image" {
  value = data.oci_core_images.amd_os_image.images[0].display_name
}

output "ssh_private_key" {
  value = tls_private_key.ssh_key.private_key_openssh
  sensitive = true
}

output "ssh_public_key" {
  value = tls_private_key.ssh_key.public_key_openssh
}
