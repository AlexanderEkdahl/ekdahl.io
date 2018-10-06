variable "subdomain" {}
variable "shared_secret" {}
variable "username" {}
variable "password" {}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_route53_zone" "primary" {
   name = "ekdahl.io"
}

module "www" {
  source = "./www"
  zone_id = "${aws_route53_zone.primary.zone_id}"
}

// module "vpn" {
//   source = "./vpn"
//   zone_id = "${aws_route53_zone.primary.zone_id}"
//   subdomain = "${var.subdomain}"
//   shared_secret = "${var.shared_secret}"
//   username = "${var.username}"
//   password = "${var.password}"
// }

// Zoho Email
resource "aws_route53_record" "email" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name = "ekdahl.io"
  ttl = 300
  type = "MX"
  records = [
    "10 mx.zoho.com.",
    "20 mx2.zoho.com."
  ]
}

// Zoho SPF and Keybase site verification
resource "aws_route53_record" "txt" {
   zone_id = "${aws_route53_zone.primary.zone_id}"
   name = "ekdahl.io"
   type = "TXT"
   ttl = "300"
   records = [
    "v=spf1 mx include:zoho.com ~all", // Zoho
    "keybase-site-verification=FTXUbkJFBxaXJlvrCSrVemhq1ls7gdvo0kG9CazTrc0" // Keybase
  ]
}

// DKIM
resource "aws_route53_record" "dkim" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name = "ekdahl._domainkey.ekdahl.io"
  type = "TXT"
  ttl = "300"
  records = ["v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCALmYxFPwybwcJwiInzlzfE4c8JF3xk8KIprE0emXebqJEsmdfZ4ExEoDRmEryntzFHG9tASnKcQzPqeLadih3OD4F6DPhl3/A4tfifi8HGg7cIL7dqj3ixYqOxecehzKzq2ojvfL4zPfZdcmQx0hEY1OeNFWqp3rDMnVs1B93uwIDAQAB"]
}

output "ns1" {
  value = "${aws_route53_zone.primary.name_servers.0}"
}

output "ns2" {
  value = "${aws_route53_zone.primary.name_servers.1}"
}

output "ns3" {
  value = "${aws_route53_zone.primary.name_servers.2}"
}

output "ns4" {
  value = "${aws_route53_zone.primary.name_servers.3}"
}
