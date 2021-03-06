# Used to get Account ID
data "aws_caller_identity" "current" {}

### S3 Bucket placed behind CloudFront
variable "bucket_name" {}
resource "aws_s3_bucket" "b" {
  bucket = var.bucket_name
  acl    = "private"

  #  versioning {
  #    enabled = true
  #  }

  tags = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_policy" "b" {
  bucket = aws_s3_bucket.b.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_cloudfront_origin_access_identity.oai.iam_arn}"
            },
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.bucket_name}/*"
            ]
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_object" "html" {
  bucket       = var.bucket_name
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
  etag         = filemd5("index.html")
}

resource "aws_s3_bucket_object" "image" {
  bucket       = var.bucket_name
  key          = "/static/terrascan_logo.png"
  source       = "terrascan_logo.png"
  content_type = "image/png"
  etag         = filemd5("terrascan_logo.png")
}

