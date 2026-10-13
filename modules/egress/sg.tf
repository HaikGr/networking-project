data "aws_region" "current" {}

data "aws_prefix_list" "s3" {
  name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

data "aws_prefix_list" "dynamodb" {
  name = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
}

resource "aws_security_group" "nat_instance" {
  name        = "${var.name}-sg"
  description = "Security group for NAT instance"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.name}-sg"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = var.managed_by
  }
}

# 1. Allow administration from your laptop
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.nat_instance.id

  cidr_ipv4   = var.admin_cidr
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"

  description = "Allow SSH administration from trusted IP"

  tags = {
    Name        = "${var.name}-ssh"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = var.managed_by
  }
}

# 2. Allow private subnet workloads to use the NAT instance
resource "aws_vpc_security_group_ingress_rule" "nat_from_private" {
  security_group_id = aws_security_group.nat_instance.id

  cidr_ipv4   = var.private_subnet_cidr
  ip_protocol = "-1"

  description = "Allow private subnet traffic through NAT instance"

  tags = {
    Name        = "${var.name}-nat-from-private"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = var.managed_by
  }
}

# 3. Allow NAT instance to send traffic outward
resource "aws_vpc_security_group_egress_rule" "nat_to_internet" {
  security_group_id = aws_security_group.nat_instance.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  description = "Allow NAT instance outbound internet traffic"

  tags = {
    Name        = "${var.name}-sg-egress"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = var.managed_by
  }
}

resource "aws_security_group" "indexer" {
  name        = "${var.name}-indexer"
  description = "Egress for the indexer Lambda"
  vpc_id      = var.vpc_id

  egress {
    description     = "HTTPS to S3"
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    prefix_list_ids = [data.aws_prefix_list.s3.id]
  }

  egress {
    description     = "HTTPS to DynamoDB"
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    prefix_list_ids = [data.aws_prefix_list.dynamodb.id]
  }

  tags = {
    Name        = "${var.name}-indexer"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_ssm_parameter" "sg_indexer_id" {
  name  = "/networking/${var.environment}/data/sg_indexer_id"
  type  = "String"
  value = aws_security_group.indexer.id
}


##############

resource "aws_network_acl" "lambda_test" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [var.private_subnet_id]

  # Rule 100: block Lambda's TCP return traffic during the experiment.
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = var.deny_ephemeral_returns ? "deny" : "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Rule 110: allow all other inbound IPv4 traffic.
  ingress {
    rule_no    = 110
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  # Leave outbound traffic permitted so the experiment isolates
  # the inbound return-traffic failure.
  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.name}-lambda-n4-test"
  }
}