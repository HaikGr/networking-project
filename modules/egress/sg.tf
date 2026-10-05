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

resource "aws_vpc_security_group_ingress_rule" "nat_from_private" {
  # for_each = toset(var.private_subnet_cidrs)

  security_group_id = aws_security_group.nat_instance.id
  cidr_ipv4         = var.private_subnet_cidr
  ip_protocol       = "-1"

  description = "Allow private subnet traffic through NAT instance"

  tags = {
    Name        = "${var.name}-sg-ingress-${var.private_subnet_cidr}"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = var.managed_by
  }
}

resource "aws_vpc_security_group_egress_rule" "nat_to_internet" {


  security_group_id = aws_security_group.nat_instance.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  description = "Allow NAT instance outbound internet traffic"

  tags = {
    Name        = "${var.name}-sg-egress-rule"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = var.managed_by
  }
}