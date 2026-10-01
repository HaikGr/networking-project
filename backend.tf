terraform {
  backend "s3" {
    bucket       = "terraform-state-bucket-haik"
    key          = "main/networking/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}