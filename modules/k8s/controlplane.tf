data "oci_core_images" "cp_os_image" {
    compartment_id = var.compartment_id
    display_name = var.cp_config.os_image
    shape = var.cp_config.shape
    state = "AVAILABLE"
    sort_by = "TIMECREATED"
    sort_order = "DESC"
}

resource "oci_core_instance" "control_plane_node" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain

  shape               = var.cp_config.shape
  source_details {
    source_id   = data.oci_core_images.cp_os_image.images[0].id
    source_type = "image"
  }
  # Optional
  display_name = "${var.prefix}-control-plane"
  shape_config {
    ocpus         = var.cp_config.ocpus
    memory_in_gbs = var.cp_config.memory_in_gbs
  }
  create_vnic_details {
    assign_public_ip = true
    subnet_id        = oci_core_subnet.public_subnet.id
    private_ip       = var.cp_config.private_ip
  }
  metadata = {
    ssh_authorized_keys = tls_private_key.ssh_key.public_key_openssh
    user_data           = filebase64("${path.module}/${var.k8s_controlplane_script}")
  }
  preserve_boot_volume = false
}