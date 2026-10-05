data "aws_region" "current" {}

data "aws_ssm_parameter" "s3_bucket_arn" {
  name = "/networking/${var.environment}/data/s3-bucket-arn"
}

data "aws_ssm_parameter" "dynamodb_table_arn" {
  name = "/networking/${var.environment}/data/dynamodb-table-arn"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = var.private_route_table_ids

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "AllowSpecificS3Buckets"
        Effect    = "Allow"
        Principal = "*"

        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]

        Resource = concat(
          var.s3_bucket_arns,
          [
            for bucket_arn in var.s3_bucket_arns :
            "${bucket_arn}/*"
          ]
        )
      }
    ]
  })

  tags = {
    Name        = "${var.name}-s3-endpoint"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = var.managed_by
  }
}


resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_endpoint_type = "Gateway"

  route_table_ids = var.private_route_table_ids

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "AllowSpecificDynamoDBTable"
        Effect    = "Allow"
        Principal = "*"

        Action = [
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem"
        ]

        Resource = var.dynamodb_table_arn
      }
    ]
  })

  tags = {
    Name        = "${var.name}-dynamodb-endpoint"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = var.managed_by
  }
}