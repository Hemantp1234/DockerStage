terraform {
  backend "s3" {
    bucket         = "hemant-tf-state-dockerstage-2026" # Same bucket name from Step 1
    key            = "global/s3/terraform.tfstate"
    region         = "ap-south-1"
    use_lockfile   = true
    encrypt        = true
  }
}