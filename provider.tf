provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn     = "arn:aws:iam::450315222519:role/jenkins-terraform-role"
    session_name = "jenkins-terraform"
  }
}