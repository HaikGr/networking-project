output "s3_endpoint_id" {
  value       = aws_vpc_endpoint.s3.id
  description = "ID of the S3 gateway endpoint."
}

output "dynamodb_endpoint_id" {
  value       = aws_vpc_endpoint.dynamodb.id
  description = "ID of the DynamoDB gateway endpoint."
}

output "s3_prefix_list_id" {
  value       = aws_vpc_endpoint.s3.prefix_list_id
  description = "AWS-managed prefix list ID used by the S3 endpoint."
}

output "dynamodb_prefix_list_id" {
  value       = aws_vpc_endpoint.dynamodb.prefix_list_id
  description = "AWS-managed prefix list ID used by the DynamoDB endpoint."
}