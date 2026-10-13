# vpc.tf

resource "aws_vpc" "main" {
  cidr_block = var.cidr

  tags = {
    Name        = var.name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = var.managed_by
  }
}

resource "aws_subnet" "public_subnet" {
  # count             = length(var.public_subnet_cidrs).  changed to be one
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.az

  tags = {
    Name        = "${var.name}-public-sn-${var.az}"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = var.managed_by
  }
}

resource "aws_subnet" "private_subnet" {
  # count             = length(var.private_subnet_cidrs).  changed to be one
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.az

  tags = {
    Name        = "${var.name}-private-sn-${var.az}"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = var.managed_by
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.name}-gw-${var.az}"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = var.managed_by
  }
}

resource "aws_route_table" "rt_public" {
  # count = length(var.azs) changed to one az

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name        = "${var.name}-public-rt-${var.az}"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = var.managed_by
  }
}

resource "aws_route_table_association" "public" {
  # count = length(var.public_subnet_cidrs).  changed to be one

  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table" "private" {
  # count = length(var.azs)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block  = "0.0.0.0/0"
    network_interface_id = var.nat_instance_network_interface_id
  }


  tags = {
    Name        = "${var.name}-private-rt-${var.az}"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = var.managed_by
  }
}

resource "aws_route_table_association" "private" {
  # count = length(var.private_subnet_cidrs)

  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private.id
}

resource "aws_ssm_parameter" "private_subnet_id" {
  name  = "/networking/${var.environment}/data/private_subnet_id"
  type  = "String"
  value = aws_subnet.private_subnet.id
}

resource "aws_ssm_parameter" "vpc_id" {
  name  = "/networking/${var.environment}/data/vpc_id"
  type  = "String"
  value = aws_vpc.main.id
}

###################

data "aws_iam_policy_document" "assume_role_vpc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "vpc_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "vpc_logging" {
  name   = "${var.name}-vpc-flow-logs-policy"
  policy = data.aws_iam_policy_document.vpc_logging.json
}

resource "aws_iam_role" "iam_for_vpc" {
  name               = "${var.name}-vpc-flow-logs-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_vpc.json
}

resource "aws_iam_role_policy_attachment" "vpc_logs" {
  role       = aws_iam_role.iam_for_vpc.name
  policy_arn = aws_iam_policy.vpc_logging.arn
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/${var.name}/flow-logs"
  retention_in_days = 7
}

resource "aws_flow_log" "vpc" {
  vpc_id                   = aws_vpc.main.id
  traffic_type              = "ALL"
  log_destination_type      = "cloud-watch-logs"
  log_destination           = aws_cloudwatch_log_group.vpc_flow_logs.arn
  iam_role_arn              = aws_iam_role.iam_for_vpc.arn
  max_aggregation_interval  = 60
  depends_on = [
    aws_iam_role_policy_attachment.vpc_logs
  ]
}