# 1. S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "hemant-tf-state-dockerstage-2026" # Must be globally unique
  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }
}



# 3. Enable Server-Side Encryption by Default
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_crypto" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 4. Block All Public Access to the Bucket
resource "aws_s3_bucket_public_access_block" "terraform_state_public" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}