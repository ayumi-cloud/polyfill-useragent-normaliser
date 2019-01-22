provider "fastly" {
  version = "0.1.2"
}

variable "domain" {
  type    = "string"
  default = "test.in.ft.com"
}

variable "name" {
  type    = "string"
  default = "Origami Polyfill Service"
}

output "service_id" {
  value = ["${fastly_service_v1.app.id}"]
}

resource "fastly_service_v1" "app" {
  name = "polyfill-useragent-normaliser"

  force_destroy = false

  domain {
    name = "${var.domain}"
  }

  vcl {
    name    = "main.vcl"
    content = "${file("${path.module}/../vcl/main.vcl")}"
    main    = true
  }
}