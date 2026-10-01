module "network" {
    source = "./modules/vpc"

    environment = "dev"
    owner = "devops"
    managed_by = "devops"
    name = "network"
    azs = ["us-east-1a", "us-east-1b"]
}