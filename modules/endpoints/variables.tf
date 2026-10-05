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

variable "dynamodb_table_arn" {
    type = string
    description = "ARN of dynamodb table"
}

variable "s3_bucket_arns" {
  type        = list(string)
  description = "ARNs of S3 buckets that the endpoint is allowed to access."
}

variable "private_route_table_ids" {
  type        = list(string)
  description = "IDs of the private route tables to associate with the gateway endpoints."
}

variable "vpc_id" {
    type = string
    description = "IP of my VPC claimed by another module"
}