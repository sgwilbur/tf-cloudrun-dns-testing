## 
## Example
##
#
# Outputs:
#
# dns = {
#   "helloservice.gcp.lab.perficientdevops.com" = [
#     {
#       "name" = "helloservice"
#       "rrdatas" = [
#         "ghs.googlehosted.com.",
#       ]
#       "type" = "CNAME"
#     },
#   ]
# }
# url = https://hello-app-ht5r4voqha-uc.a.run.app
#


## 
## cloud run module outputs
## https://registry.terraform.io/modules/garbetjie/cloud-run/google/latest?tab=outputs
##
output "dns" {
  value = module.cloud_run_hello.dns
}

output "url" {
  value = module.cloud_run_hello.url
}