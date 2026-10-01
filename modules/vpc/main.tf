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

# resource "aws_subnet" "public" {

#   for_each = var.availability_zones

#   vpc_id            = aws_vpc.main.id
#   availability_zone = each.key
  
#   cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, each.value)

#   tags = {
#     Name = "public-subnet-${each.key}"
#     Environment = var.environment
#     Owner       = var.owner
#     ManagedBy   = var.managed_by
#   }
# }


resource "aws_subnet" "public_subnets" {
 count      = length(var.public_subnet_cidrs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.public_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "Public Subnet ${count.index + 1}"
   Environment = var.environment
   Owner       = var.owner
   ManagedBy   = var.managed_by
 }
}
 
resource "aws_subnet" "private_subnets" {
 count      = length(var.private_subnet_cidrs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.private_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "Private Subnet ${count.index + 1}"
   Environment = var.environment
   Owner       = var.owner
   ManagedBy   = var.managed_by
 }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = var.name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = var.managed_by
  }
}


resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name        = var.name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = var.managed_by
  }
}

resource "aws_route_table_association" "stw_rta_public_1" {
  subnet_id      = aws_subnet.stw_subnet_public_1.id
  route_table_id = aws_route_table.stw_rt_public.id
}
resource "aws_route_table_association" "stw_rta_public_2" {
  subnet_id      = aws_subnet.stw_subnet_public_2.id
  route_table_id = aws_route_table.stw_rt_public.id
}