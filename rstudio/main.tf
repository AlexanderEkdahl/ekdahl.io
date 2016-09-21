variable "zone_id" {}
variable "ami" {
  default = "ami-41f4212f"
}

provider "aws" {
  alias = "ap-northeast-2"

  region = "ap-northeast-2"
}

resource "aws_instance" "rstudio" {
  provider = "aws.ap-northeast-2"
  ami = "${var.ami}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.rstudio.name}"]
}

resource "aws_security_group" "rstudio" {
  provider = "aws.ap-northeast-2"
  name = "default-sg-rstudio"
  description = "Security group for web"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route53_record" "rstudio" {
  zone_id = "${var.zone_id}"
  name = "rstudio.ekdahl.io"
  type = "A"
  ttl = 300
  records = ["${aws_instance.rstudio.public_ip}"]
}
