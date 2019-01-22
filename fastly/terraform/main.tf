provider "fastly" {
  version = "0.1.2"
}

resource "fastly_service_v1" "app" {
  name = "polyfill-useragent-normaliser"

  force_destroy = false

  domain {
    name = "test.in.ft.com"
  }

  vcl {
    name    = "main.vcl"
    content = "${file("${path.module}/../vcl/main.vcl")}"
    main    = true
  }
}