terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

variable "account_id" {
  type = string
}

variable "api_token" {
  type = string
}

variable "domain" {
  type = string
}

variable "bucket" {
  type = string
}

provider "cloudflare" {
  api_token = var.api_token
}

resource "cloudflare_zone" "zone" {
  account_id = var.account_id
  zone       = var.domain
}

resource "cloudflare_worker_route" "route" {
  zone_id     = cloudflare_zone.zone.id
  pattern     = "${cloudflare_zone.zone.zone}/*"
  script_name = cloudflare_worker_script.script.name
}

resource "cloudflare_worker_script" "script" {
  account_id = var.account_id
  name       = "script"
  content    = file("../workers-sdk/templates/examples/fast-google-fonts/fast-google-fonts.js")

  /*
  r2_bucket_binding {
    name        = "BUCKET"
    bucket_name = var.bucket
  }
  */
}

resource "cloudflare_worker_domain" "example" {
  account_id = var.account_id
  hostname   = "worker.${cloudflare_zone.zone.zone}"
  service    = cloudflare_worker_script.script.name
  zone_id    = cloudflare_zone.zone.id
}
