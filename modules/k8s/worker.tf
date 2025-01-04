data "oci_core_images" "worker_os_image" {
    count = length(var.worker_config)

    compartment_id = var.compartment_id
    display_name = var.worker_config[count.index].os_image
    shape = var.worker_config[count.index].shape
    state = "AVAILABLE"
    sort_by = "TIMECREATED"
    sort_order = "DESC"
}

resource "oci_core_instance" "worker_node" {
    count = length(var.worker_config)

    compartment_id = var.compartment_id
    availability_domain = var.availability_domain
    shape = var.worker_config[count.index].shape

    source_details {
        source_id = data.oci_core_images.worker_os_image[count.index].images[0].id
        source_type = "image"
    }
    # Optional
    display_name = "${var.prefix}-worker-${count.index}"
    shape_config {
        ocpus = var.worker_config[count.index].ocpus
        memory_in_gbs = var.worker_config[count.index].memory_in_gbs
    }
    create_vnic_details {
        assign_public_ip = true
        subnet_id = oci_core_subnet.public_subnet.id
        private_ip = var.worker_config[count.index].private_ip
    }
    metadata = {
        ssh_authorized_keys = tls_private_key.ssh_key.public_key_openssh
        user_data = filebase64("${path.module}/${var.k8s_worker_script}")
    } 
    preserve_boot_volume = false
}