
##
## Configure the Google Cloud provider
##
provider "google" {
 credentials = file(var.credfile)
 project     = var.project_id
 region      = var.region
}

locals {
  dns_name = "${var.servicename}.${var.subdomain}"

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
resource "google_dns_managed_zone" "gcp_lab" {
  name        = var.zonename
  dns_name    = var.domain
  labels = {
    foo = "bar"
  }
}

##
## Use module to instantiate a cloudrun service
## 
## N.B Ensure the service account is added to the verification property for this domain
## at https://www.google.com/webmasters/verification/home?hl=en
##
module cloud_run_hello {
  source = "garbetjie/cloud-run/google"
  version = "= 1.0"
  name = "hello-app"
  image =  "gcr.io/google-samples/hello-app:1.0"
  location = "us-central1"

  allow_public_access = true # false
  memory = 128
  min_instances = 2
  max_instances = 3

  map_domains = [local.dns_name]
}

##
## Create DNS recordsets
## 
resource "google_dns_record_set" "api_run_dns_record_set" {
  for_each = { for rs in lookup(module.cloud_run_hello.dns, local.dns_name, []): rs.name => rs }

    project = var.project_id
    managed_zone = var.zonename
    name = "${each.value.name}.${var.subdomain}."
    type = each.value.type
    rrdatas = each.value.rrdatas
    ttl = 300
}