// The annex bucket is hosted in the Ireland region
provider "aws" {
  alias = "eu-west-1"

  region = "eu-west-1"
}

resource "aws_s3_bucket" "annex" {
  provider = "aws.eu-west-1"
  bucket = "alexanderekdahl-annex"
}

resource "aws_iam_user" "annex" {
  name = "annex"
}

resource "aws_iam_access_key" "annex" {
  user = "${aws_iam_user.annex.name}"
}

resource "aws_iam_user_policy" "annex" {
    name = "annex"
    user = "${aws_iam_user.annex.name}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.annex.id}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.annex.id}/*"]
    }
  ]
}
EOF
}

output "access_key" {
  value = "${aws_iam_access_key.annex.id}"
}

output "secret_key" {
  value = "${aws_iam_access_key.annex.secret}"
}
