variable "zone_id" {}

data "template_file" "policy" {
  template = "${file("${path.module}/policy.json")}"

  vars {
    bucket_name = "ekdahl.io"
  }
}

resource "aws_s3_bucket" "primary" {
  bucket = "ekdahl.io"
  acl    = "public-read"
  policy = "${data.template_file.policy.rendered}"

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket" "secondary" {
  bucket = "www.ekdahl.io"
  acl    = "public-read"

  website {
    redirect_all_requests_to = "ekdahl.io"
  }
}

resource "aws_s3_bucket_object" "index" {
  bucket       = "${aws_s3_bucket.primary.id}"
  key          = "index.html"
  content      = "${file("${path.module}/index.html")}"
  content_type = "text/html"
}

resource "aws_route53_record" "primary" {
  zone_id = "${var.zone_id}"
  name    = "ekdahl.io"
  type    = "A"

  alias {
    name = "${aws_s3_bucket.primary.website_domain}"

    //zone_id = "${aws_s3_bucket.primary.hosted_zone_id}"
    zone_id                = "Z21DNDUVLTQW6Q"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "secondary" {
  zone_id = "${var.zone_id}"
  name    = "www.ekdahl.io"
  type    = "A"

  alias {
    name = "${aws_s3_bucket.secondary.website_domain}"

    //zone_id = "${aws_s3_bucket.secondary.hosted_zone_id}"
    zone_id                = "Z21DNDUVLTQW6Q"
    evaluate_target_health = false
  }
}
