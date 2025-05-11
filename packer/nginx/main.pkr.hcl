packer {
  required_plugins {
    googlecompute = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/googlecompute"
    }
    ansible = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "project_id" {}
variable "region" {}
variable "image_name_prefix" {}

source "googlecompute" "ubuntu" {
  project_id            = var.project_id
  source_image_family   = "ubuntu-2204-lts"
  source_image_project_id = ["ubuntu-os-cloud"]
  zone                  = "${var.region}-b"
  machine_type          = "e2-micro"
  disk_size             = 10
  ssh_username          = "packer"
  image_name   = "nginx-image-{{timestamp}}"
  image_family = "nginx-latest"
}

build {
  name    = "nginx-webserver-image"
  sources = ["source.googlecompute.ubuntu"]

  provisioner "ansible" {
    playbook_file = "${path.root}/ansible/playbook.yml"
    extra_arguments = [
      "--extra-vars", "ansible_remote_tmp=/tmp/.ansible"
    ]
    use_proxy = false
  }
}

