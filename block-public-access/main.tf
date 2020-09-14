### AWS Provider
variable "aws_region" {}
provider "aws" {
  region = var.aws_region
}

### S3 Account Public Access Block
resource "aws_s3_account_public_access_block" "block_it" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

/*
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
*/
