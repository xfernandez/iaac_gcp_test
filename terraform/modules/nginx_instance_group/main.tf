data "google_compute_image" "nginx_latest" {
  family  = var.image_family
  project = var.project_id
}

resource "google_compute_instance_template" "template" {
  name_prefix   = "nginx-${var.environment}-"
  project       = var.project_id
  region        = var.region
  machine_type  = "e2-micro"

  tags = ["nginx", var.environment]

  scheduling {
    preemptible       = var.use_spot
    automatic_restart = !var.use_spot
  }

  disk {
    source_image = data.google_compute_image.nginx_latest.self_link
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network       = "default"
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    systemctl start nginx
  EOT
}

resource "google_compute_firewall" "allow_health_check" {
  name    = "allow-health-check-${var.environment}"
  network = "default"
  project = var.project_id

  direction     = "INGRESS"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["nginx"]
  priority      = 1000

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  description = "Permite el tráfico de los health checks de Google Cloud al puerto 80"
}


resource "google_compute_instance_group_manager" "mig" {
  name               = "nginx-mig-${var.environment}"
  zone               = var.zone
  project            = var.project_id
  base_instance_name = "nginx-${var.environment}"
  target_size        = var.instance_count

  version {
    instance_template = google_compute_instance_template.template.self_link
  }

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_health_check" "hc" {
  name    = "nginx-health-check"
  project = var.project_id

  http_health_check {
    port         = 80
    request_path = "/"
  }
}

resource "google_compute_backend_service" "backend" {
  name    = "nginx-backend-${var.environment}"
  project = var.project_id

  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 30

  backend {
    group = google_compute_instance_group_manager.mig.instance_group
  }

  health_checks = [google_compute_health_check.hc.self_link]

  session_affinity = "NONE"
  load_balancing_scheme = "EXTERNAL"
  
  enable_cdn = false
}

resource "google_compute_url_map" "url_map" {
  name    = "nginx-urlmap-${var.environment}"
  project = var.project_id

  default_service = google_compute_backend_service.backend.self_link
}

resource "google_compute_target_http_proxy" "proxy" {
  name    = "nginx-proxy-${var.environment}"
  project = var.project_id

  url_map = google_compute_url_map.url_map.self_link
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name        = "nginx-forwarding-${var.environment}"
  project     = var.project_id
  ip_protocol = "TCP"
  port_range  = "80"
  target      = google_compute_target_http_proxy.proxy.self_link
}
