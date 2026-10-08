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