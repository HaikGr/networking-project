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

variable "name" {
    type = string
    description = "name of resource creator."
}

variable "cidr" {
    type = string
    description = "The IPv4 CIDR block for the VPC."
    default = "10.0.0.0/16"
}

variable "az" {
    type = string
    description = "A list of availability zones names or ids in the region."
}

variable "public_subnet_cidr" {
 type        = string
 description = "Public Subnet CIDR values."
 default     = "10.0.1.0/24"
}
 
variable "private_subnet_cidr" {
 type        = string
 description = "Private Subnet CIDR values."
 default     = "10.0.2.0/24"
}

variable "nat_instance_network_interface_id" {
    type = string
    description = "EC2 nat instance id for route table"
}