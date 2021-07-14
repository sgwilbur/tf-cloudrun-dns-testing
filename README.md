# Purpose

Investigation of an issue with the behavior of a DNS mapping to a cloudrun service.

Experiment is to create a cloudrun service using the [garbetjie/cloud-run/google](https://registry.terraform.io/modules/garbetjie/cloud-run/google/latest) module and map that onto a dns entry in a hosted zone using [terraform-google-modules/cloud-dns/google](https://registry.terraform.io/modules/terraform-google-modules/cloud-dns/google/latest) [source](https://github.com/terraform-google-modules/terraform-google-cloud-dns/blob/master/main.tf)


# Usage with specific version of Terraform

The version is important for this so simplest thing to do is to use a helper docker image for this. The basic flow is to call docker with a throw away container mapping the current working directory onto the container.

    docker run --rm -it -w /work -v $(pwd):/work hashicorp/terraform:0.13.0 <command>
