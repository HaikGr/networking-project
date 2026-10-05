variable "environment" {
  type        = string
  description = "Environment of this file."
}

variable "owner" {
    type = string
    description = "Owner of this vpc."
}

variable "managed_by" {
    type = string
    description = "Managed by who."
}

variable "private_subnet_cidr" {
 type        = string
 description = "Private Subnet CIDR values."
}

variable "name" {
    type = string
    description = "name of resource creator."
}

variable "vpc_id" {
    type = string
    description = "IP of my VPC claimed by another module"
}

variable "public_subnet_id" {
    type = string
    description = "Id of public subnets created via vpc module"
}