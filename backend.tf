terraform {
  backend "s3" {
    bucket       = "terraform-state-bucket-haik"
    key          = "main/networking/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true

    assume_role = {
      role_arn = "arn:aws:iam::450315222519:role/jenkins-terraform-role"
    }
  }
}