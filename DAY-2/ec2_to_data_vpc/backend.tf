terraform {
  backend "s3" {
    bucket       = "terraform-journey-101"
    key          = "day2/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

