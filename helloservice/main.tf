
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
## Use module to instantiate a cloudrun service
## the `garbetjie/cloud-run/google` helper module is a wrapper around:
##  * google_cloud_run_service - to create service
##  * google_cloud_run_service_iam_member - to setup access
##  * google_cloud_run_domain_mapping - to map service to domains
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

## Scenario #1 - If we have more than one result we need to loop, this will require a two phase apply
## or to restructure the plans so these happen independently.
## 
# resource "google_dns_record_set" "dns_record_set" {
#   for_each = { for rs in lookup(module.cloud_run_hello.dns, local.dns_name, []): rs.name => rs }

#     project = var.project_id
#     managed_zone = var.zonename
#     name = "${each.value.name}.${var.subdomain}."
#     type = each.value.type
#     rrdatas = each.value.rrdatas
#     ttl = 300
# }


## Scenario #2 - If we assume that we will only get 1 CNAME record in the dns object
## 
locals {

  cloudrun_cname = module.cloud_run_hello.dns[local.dns_name][0]
}

resource "google_dns_record_set" "dns_record_set" {
    project = var.project_id
    managed_zone = var.zonename
    name = "${local.cloudrun_cname.name}.${var.subdomain}."
    type = local.cloudrun_cname.type
    rrdatas = local.cloudrun_cname.rrdatas
    ttl = 300
}