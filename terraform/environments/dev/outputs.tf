output "load_balancer_ip" {
  description = "Dirección IP pública del Load Balancer"
  value       = module.nginx.load_balancer_ip
}
