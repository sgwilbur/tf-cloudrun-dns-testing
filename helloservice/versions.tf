terraform {
  required_version = "~> 0.13.0"

  # # https://www.terraform.io/docs/language/providers/requirements.html
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=2.46.0"
    }
  }
}