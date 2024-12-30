data "oci_core_images" "arm_os_image" {
    compartment_id = var.tenancy_ocid
    # display_name = "Canonical-Ubuntu-22.04-Minimal-aarch64-2024.10.06-0"
    display_name = "Oracle-Linux-9.4-aarch64-2024.09.30-0"
    # operating_system = "Oracle Linux"
    # operating_system_version = "9 Minimal"
    # display_name = var.arm_os_image
    shape = "VM.Standard.A1.Flex"
    state = "AVAILABLE"
    sort_by = "TIMECREATED"
    sort_order = "DESC"
}

data "oci_core_images" "amd_os_image" {
    compartment_id = var.tenancy_ocid
    # display_name = "Canonical-Ubuntu-22.04-Minimal-2024.10.06-0"
    # display_name = "Oracle-Linux-9.4-2024.09.30-0"
    display_name = "Oracle-Linux-9.4-Minimal-2024.07.29-0"
    # operating_system = "Oracle Linux"
    # operating_system_version = "9 Minimal"
    # display_name = var.amd_os_image
    shape = "VM.Standard.E2.1.Micro"
    state = "AVAILABLE"
    sort_by = "TIMECREATED"
    sort_order = "DESC"
}