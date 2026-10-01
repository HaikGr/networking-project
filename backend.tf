terraform {
  backend "s3" {
    bucket       = "terraform-state-bucket-haik"
    key          = "main/networking/terraform.tfstate"
    use_lockfile = true
    encrypt      = true
  }
}