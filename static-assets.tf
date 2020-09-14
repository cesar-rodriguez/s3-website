# Used to get Account ID
data "aws_caller_identity" "current" {}

### S3 Bucket hosting website
variable "bucket_name" {}
resource "aws_s3_bucket" "b" {
  bucket = var.bucket_name
  acl    = "public-read"

  website {
    index_document = "index.html"
  }

  tags = {
    Name = var.bucket_name
  }
}
output "index_html" {
  value = "http://${aws_s3_bucket.b.bucket_domain_name}/index.html"
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
            "Principal": "*",
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
  bucket       = aws_s3_bucket.b.bucket
  key          = "index.html"
  source       = "index.html"
  acl          = "public-read"
  content_type = "text/html"
  etag         = filemd5("index.html")
}

resource "aws_s3_bucket_object" "image" {
  bucket       = aws_s3_bucket.b.bucket
  key          = "/static/terrascan_logo.png"
  source       = "terrascan_logo.png"
  acl          = "public-read"
  content_type = "image/png"
  etag         = filemd5("terrascan_logo.png")
}
