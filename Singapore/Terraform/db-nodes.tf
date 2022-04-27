resource "google_compute_instance" "db-nodes" {
  count        = 3
  name         = var.db_vm_names[count.index]
  machine_type = var.machine_type
  zone         = var.zones[count.index]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }
  network_interface {
    network    = var.network_name
    subnetwork = var.subnetwork
    network_ip = var.db-ip[count.index]
  }

  metadata = {
    ssh-keys = "${"eshamaaqib"}:${file("/home/eshamaaqib/.ssh/id_rsa.pub")}"
  }

  tags = ["db-cluster"]
}

resource "google_compute_subnetwork" "default" {
  name          = var.lb_subnet_name
  ip_cidr_range = var.lb_subnet_cidr
  region        = var.region
  network       = var.network_name
}

resource "google_compute_address" "loadbalancer-ip" {
  name         = var.lb_ip_name
  subnetwork   = google_compute_subnetwork.default.id
  address_type = "INTERNAL"
  address      = var.lb_ip
  region       = var.region
}

resource "google_compute_forwarding_rule" "db-loadbalancer" {
  name                  = var.lb_name
  backend_service       = google_compute_region_backend_service.default.id
  region                = var.region
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL"
  all_ports             = true
  allow_global_access   = true
  network               = var.network_name
  subnetwork            = google_compute_subnetwork.default.id
  network_tier          = "PREMIUM"
  ip_address            = google_compute_address.loadbalancer-ip.address
  service_label         = var.lb_service_label
}

output "db-load-balancer-ip-address" {
  value = google_compute_forwarding_rule.db-loadbalancer.ip_address
}

# backend service
resource "google_compute_region_backend_service" "default" {
  name                  = var.backend_name
  region                = var.region
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_region_health_check.default.id]
  backend {
    group          = google_compute_instance_group.dbnodes[0].id
    balancing_mode = "CONNECTION"
  }
  backend {
    group          = google_compute_instance_group.dbnodes[1].id
    balancing_mode = "CONNECTION"
  }
  backend {
    group          = google_compute_instance_group.dbnodes[2].id
    balancing_mode = "CONNECTION"
  }
}

# health check
resource "google_compute_region_health_check" "default" {
  name                = var.health_check_name
  region              = var.region
  timeout_sec         = 1
  check_interval_sec  = 1
  healthy_threshold   = 4
  unhealthy_threshold = 5
  tcp_health_check {
    port = "3306"
  }
}

resource "google_compute_instance_group" "dbnodes" {
  count = 3
  name  = var.resource_group[count.index]
  zone  = var.zones[count.index]
  instances = [
    google_compute_instance.db-nodes[count.index].self_link,
  ]
  named_port {
    name = "tcp"
    port = "3306"
  }
}

resource "google_compute_firewall" "db-to-lb-fw" {
  name          = "allow-db-loadbalancers"
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  network       = var.network_name
  allow {
    protocol = "all"
  }
  target_tags = ["db-cluster"]

}








