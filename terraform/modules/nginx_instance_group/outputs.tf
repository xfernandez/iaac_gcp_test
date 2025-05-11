output "load_balancer_ip" {
  description = "Dirección IP pública del Load Balancer"
  value       = google_compute_global_forwarding_rule.forwarding_rule.ip_address
}
