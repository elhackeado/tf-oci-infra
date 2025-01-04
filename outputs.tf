output "ssh_private_key" {
  value = module.k8s.ssh_private_key
  sensitive = true
}

output "ssh_public_key" {
  value = module.k8s.ssh_public_key
}

output "nlb_public_ip" {
  value = module.k8s.nlb_public_ip
}