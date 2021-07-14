
##
## Configure the Google Cloud provider
##
provider "google" {
 credentials = file(var.credfile)
 project     = var.project_id
 region      = var.region
}

##
## Enable APIs for this project
## * Cloud DNS APIs - dns.googleapis.com
## * Cloud Run API - run.googleapis.com
## * Cloud Resource Manager - cloudresourcemanager.googleapis.com
##
resource "google_project_service" "enabled_api" {
  for_each = toset(["cloudresourcemanager.googleapis.com", "dns.googleapis.com", "run.googleapis.com"])

    project = var.project_id
    service = each.key
    disable_on_destroy = false
}

## 
## Setup some DNS to use
## 
resource "google_dns_managed_zone" "default" {
  name        = var.zonename
  dns_name    = var.domain
}