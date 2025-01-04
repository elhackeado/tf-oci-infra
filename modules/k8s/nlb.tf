# Network Load Balancer

# NSG for Network load balancer

resource "oci_core_network_security_group" "nlb_nsg" {
    #Required
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn.id

    display_name = "${var.prefix}-nlb-nsg"
}

# NSG rule
resource "oci_core_network_security_group_security_rule" "nsg_rule" {
    #Required
    network_security_group_id = oci_core_network_security_group.nlb_nsg.id
    direction = "INGRESS"
    protocol = "6"

    source = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless = false
    tcp_options {
        #Optional
        destination_port_range {
            #Required
            max = 80
            min = 80
        }
    }
}

# NLB

resource "oci_network_load_balancer_network_load_balancer" "nlb" {
    #Required
    compartment_id = var.compartment_id
    display_name = "${var.prefix}-nlb"
    subnet_id = oci_core_subnet.public_subnet.id
    assigned_private_ipv4 = var.nlb_private_ip

    #Optional
    is_preserve_source_destination = false
    is_private = false
    is_symmetric_hash_enabled = false
    network_security_group_ids = [oci_core_network_security_group.nlb_nsg.id]
    nlb_ip_version = "IPV4"
}

resource "oci_network_load_balancer_network_load_balancers_backend_sets_unified" "nlb_backend_set_unified" {
    #Required
    health_checker {
        #Required
        protocol = "TCP"
        interval_in_millis = 10000
        port = 30001
        retries = 3
        return_code = 200
        timeout_in_millis = 3000
        url_path = "/"
    }
    name = "${var.prefix}-unified-backend-set"
    network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
    policy = "FIVE_TUPLE"

    #Optional
    dynamic "backends" {
        for_each = var.worker_config
        content {
            port = 30001
            ip_address = backends.value.private_ip
            is_backup = false
            is_drain = false
            is_offline = false
            name = "${var.prefix}-worker-backend-${backends.key}"
            weight = 1
        }
    }

    backends {
        #Required
        port = 30001
        #Optional
        ip_address = var.cp_config.private_ip
        is_backup = false
        is_drain = false
        is_offline = false
        name = "${var.prefix}-controlplane-backend"
        # target_id = o
        weight = 1
    }

    ip_version = "IPV4"
    is_fail_open = false
    is_instant_failover_enabled = true
    is_preserve_source = false

    lifecycle {
        ignore_changes = [
            health_checker
        ]
    }
}

# NLB Listener
resource "oci_network_load_balancer_listener" "nlb_listener" {
    #Required
    default_backend_set_name = oci_network_load_balancer_network_load_balancers_backend_sets_unified.nlb_backend_set_unified.name
    name = "${var.prefix}-nlb-listener"
    network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
    port = var.nlb_public_port
    protocol = "TCP"

    #Optional
    ip_version = "IPV4"
    is_ppv2enabled = false
    tcp_idle_timeout = 120      # can be between 120-1800
}
