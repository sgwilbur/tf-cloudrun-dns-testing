
#å Configure the Google Cloud provider
provider "google" {
 credentials = file("intrado-cloudrun-testing-3282f442a7cd.json")
 project     = "intrado-cloudrun-testing"
 region      = "us-central1"
}

# # cloudresourcemanager.googleapis.com

# Enable Cloud DNS APIs
resource "google_project_service" "cloud_dns" {
  service = "dns.googleapis.com"

  disable_on_destroy = true
}

resource "google_dns_managed_zone" "example_zone" {
  name        = "example-zone"
  dns_name    = "example-${random_id.rnd.hex}.com."
  description = "Example DNS zone"
  labels = {
    foo = "bar"
  }
}

resource "random_id" "rnd" {
  byte_length = 4
}

# enable cloud run
# Enables the Cloud Run API
resource "google_project_service" "run_api" {
  service = "run.googleapis.com"

  disable_on_destroy = true
}

# Create the Cloud Run service
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service
resource "google_cloud_run_service" "default" {
  name = "app"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "gcr.io/google-samples/hello-app:1.0"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  # Waits for the Cloud Run API to be enabled
  depends_on = [google_project_service.run_api]
}

# Allow unauthenticated users to invoke the service
resource "google_cloud_run_service_iam_member" "run_all_users" {
  service  = google_cloud_run_service.default.name
  location = google_cloud_run_service.default.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

// recordsets = lookup(module.gcp-cloudrun-apps.cxportal-acm-service-domain-dns-records, "acm-service.${var.api_console_domain}", [])

// sent to module
// https://github.com/terraform-google-modules/terraform-google-cloud-dns/blob/master/main.tf

resource "google_cloud_run_domain_mapping" "default" {
  location = "us-central1"
  name     = "hello.$(google_dns_managed_zone.example_zone.name)"

  metadata {
    namespace = "default"
  }

  spec {
    route_name = google_cloud_run_service.default.name
  }
}