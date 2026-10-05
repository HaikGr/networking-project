data "aws_region" "current" {}

data "aws_ssm_parameter" "s3_bucket_arn" {
  name = "/networking/dev/data/s3-bucket-arn"
}

data "aws_ssm_parameter" "dynamodb_table_arn" {
  name = "/networking/dev/data/dynamodb-table-arn"
}

module "network" {
    source = "./modules/vpc"

    environment = "dev"
    owner = "devops-1"
    managed_by = "devops"
    name = "network"
    az = "us-east-1a"
    nat_instance_network_interface_id = module.egress.nat_instance_network_interface_id
}

module "egress" {
    source = "./modules/egress"

    name = "nat-instance"
    environment = "dev"
    owner = "devops-1"
    managed_by = "devops"
    private_subnet_cidr = module.network.private_subnet_cidr
    vpc_id = module.network.vpc_id
    public_subnet_id = module.network.public_subnet_id
}

module "endpoints" {
    source = "./modules/endpoints"

    vpc_id = module.network.vpc_id

    private_route_table_ids = module.network.private_route_table_ids

    s3_bucket_arns = [
    data.aws_ssm_parameter.s3_bucket_arn.value
    ]

    dynamodb_table_arn = data.aws_ssm_parameter.dynamodb_table_arn.value


    name = "endpoints"
    environment = "dev"
    owner = "devops-1"
    managed_by = "devops"
}