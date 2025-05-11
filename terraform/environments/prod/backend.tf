terraform {
  backend "gcs" {
    bucket  = "infra-holamundo-tfstate"
    prefix  = "prod"
  }
}
