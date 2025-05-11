variable "project_id" {
  description = "ID del proyecto de GCP"
  type        = string
}

variable "region" {
  description = "Región donde se desplegará la infraestructura"
  type        = string
}

variable "zone" {
  description = "Zona dentro de la región"
  type        = string
}

variable "instance_count" {
  description = "Número de instancias en el grupo"
  type        = number
}

variable "environment" {
  description = "Nombre del entorno (dev o prod)"
  type        = string
}

variable "use_spot" {
  description = "Usar VMs SPOT (preemptibles) para reducir costes"
  type        = bool
  default     = true
}

variable "image_family" {
  description = "Nombre de la familia de imágenes generadas por Packer"
  type        = string
  default     = "nginx-latest"
}