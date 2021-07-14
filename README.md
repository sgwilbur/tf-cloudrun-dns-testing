# Purpose

Investigation of an issue with the behavior of a DNS mapping to a cloudrun service.

Experiment is to create a cloudrun service using the [garbetjie/cloud-run/google](https://registry.terraform.io/modules/garbetjie/cloud-run/google/latest) module and map that onto a dns entry in a hosted zone using [terraform-google-modules/cloud-dns/google](https://registry.terraform.io/modules/terraform-google-modules/cloud-dns/google/latest) [source](https://github.com/terraform-google-modules/terraform-google-cloud-dns/blob/master/main.tf)


The issue that is coming up is that the results of the `module my_cloud_run_service` call returns a map of (dns entries)[https://github.com/garbetjie/terraform-google-cloud-run/blob/29482499c4567e5d3055171d9ceed85fb43c2bd6/outputs.tf#L167] that returns an object like this.

        dns = {
        "helloservice.gcp.lab.perficientdevops.com" = [
            {
            "name" = "helloservice"
            "rrdatas" = [
                "ghs.googlehosted.com.",
            ]
            "type" = "CNAME"
            },
        ]
        }

Looping over this object when attempting to create the record sets in the hosted zone is causing an issue with have an uknown number of resources to count over, but there is a [hitch](https://www.terraform.io/docs/language/meta-arguments/count.html#using-expressions-in-count).

        However, unlike most arguments, the count value must be known before Terraform performs any remote resource actions.

So this will produce an error like below on the first run.

        ➜  helloservice git:(master) ✗ docker run --rm -it -w /work -v $(pwd):/work hashicorp/terraform:0.13.0 apply -auto-approve
        module.cloud_run_hello.data.google_project.default: Refreshing state...

        Error: Invalid for_each argument

        on main.tf line 44, in resource "google_dns_record_set" "api_run_dns_record_set":
        44:   for_each = { for rs in lookup(module.cloud_run_hello.dns, local.dns_name, []): rs.name => rs }

        The "for_each" value depends on resource attributes that cannot be determined
        until apply, so Terraform cannot predict how many instances will be created.
        To work around this, use the -target argument to first apply only the
        resources that the for_each depends on.


So looking for other ways to make this simpler to execute, the challenge is that `dns` object returned seems to be able to be of variable type so we cannot assume that it will always only have one member like the example above. There appear to be scnearios in which this can return 4 `A` ipv4 records or `AAAA` records for ipv6.

 The goal here is to create a simple model to do some testing with cloudrun and see if we can reproduce that variability as we are trying to automate this process any variability is less than ideal and would be better if we could flesh out how to proactively ask for `CNAME` only responses so we can codify the behavior in one consistent way.


# Usage with specific version of Terraform

The version is important for this so simplest thing to do is to use a helper docker image for this. The basic flow is to call docker with a throw away container mapping the current working directory onto the container.

    docker run --rm -it -w /work -v $(pwd):/work hashicorp/terraform:0.13.0 <command>


## Setup

Create a GCP project manually and get the service account credentials.

Get your credentials from the service account and put them in a file `creds.json` or whatever you want in both `base` and `helloservice` as it must be a file within the base plan directory.

First run the `base` plan to get the project configured and to manage the hosted zone or just do these manually.

Second run the `helloservice` plan to actually stand up and expose a cloudrun service, the output of an apply will show what kind of `dns` object is returned to test our experiment here.
