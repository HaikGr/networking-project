output "private_subnet_cidr" {
    value = var.private_subnet_cidr
}

output "public_subnet_cidr" {
    value = var.public_subnet_cidr
}

output "vpc_id" {
    value = aws_vpc.main.id
}

output "public_subnet_id" {
    value = aws_subnet.public_subnet.id
}

output "private_rt_id" {
    value = aws_route_table.private.id
}