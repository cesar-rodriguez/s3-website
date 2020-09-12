### AWS Provider
variable "aws_region" {}
provider "aws" {
  region = var.aws_region
}


### CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "oai" {}

### S3 Bucket placed behind CloudFront
variable "bucket_name" {}
resource "aws_s3_bucket" "b" {
  bucket = var.bucket_name
  acl    = "private"
  #  acl    = "public-read"
  #
  #  website {
  #    index_document = "index.html"
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
  acl          = "public-read"
  content_type = "text/html"
  etag         = filemd5("index.html")
}

resource "aws_s3_bucket_object" "image" {
  bucket       = var.bucket_name
  key          = "terrascan_logo.png"
  source       = "terrascan_logo.png"
  acl          = "public-read"
  content_type = "image/png"
  etag         = filemd5("terrascan_logo.png")
}

### CloudFront Disribution
locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.b.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  default_root_object = "index.html"

  #  logging_config {
  #    include_cookies = false
  #    bucket          = "mylogs.s3.amazonaws.com"
  #    prefix          = "myprefix"
  #  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all" #"redirect-to-https"
    min_ttl                = 0
    #default_ttl            = 3600
    default_ttl = 0
    max_ttl     = 86400
    compress    = true
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

output "index_html" {
  value = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}/index.html"
}
