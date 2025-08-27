provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "terraform-journey-101"
  #force_destroy = false
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# (Optional but recommended: lifecycle rules)
# resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
#   bucket = aws_s3_bucket.tf_state.id
#   rule {
#     id     = "retain-state"
#     status = "Enabled"
#     noncurrent_version_expiration {
#       noncurrent_days = 30
#     }
#   }
# }

output "bucket_name" {
  value = aws_s3_bucket.tf_state.bucket
}