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