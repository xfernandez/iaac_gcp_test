module "nginx" {
  source         = "../../modules/nginx_instance_group"
  project_id     = var.project_id
  region         = var.region
  zone           = var.zone
  instance_count = var.instance_count
  environment    = var.environment
  use_spot       = var.use_spot
  image_family   = "nginx-latest"
}
