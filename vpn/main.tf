variable "zone_id" {}
variable "subdomain" {}
variable "shared_secret" {}
variable "username" {}
variable "password" {}
variable "region" {
  description = "AWS region to launch the VPN."
  default = "ap-northeast-1"
}
variable "amis" {
  default = {
    ap-northeast-2 = "ami-2b408b45"
    ap-northeast-1 = "ami-374db956"
  }
}

provider "aws" {
  alias = "current"

  region = "${var.region}"
}

data "template_file" "start" {
  template = "${file("${path.module}/start.sh")}"

  vars {
    shared_secret = "${var.shared_secret}"
    username = "${var.username}"
    password = "${var.password}"
  }
}

resource "aws_instance" "vpn" {
  provider = "aws.current"
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.vpn.name}"]
  user_data = "${data.template_file.start.rendered}"
}

resource "aws_security_group" "vpn" {
  provider = "aws.current"
  name = "default-sg-vpn"
  description = "Security group for web that allows inbound VPN traffic and everything outbound"

  ingress {
    from_port = 500
    to_port   = 500
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 500
    to_port   = 500
    protocol  = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 4500
    to_port   = 4500
    protocol  = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route53_record" "vpn" {
  zone_id = "${var.zone_id}"
  name = "${var.subdomain}.ekdahl.io"
  type = "A"
  ttl = 300
  records = ["${aws_instance.vpn.public_ip}"]
}
