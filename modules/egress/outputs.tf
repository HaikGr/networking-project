output "nat_instance_network_interface_id" {
  value = aws_instance.nat_instance.primary_network_interface_id
}

output "nat_instance_id" {
  value = aws_instance.nat_instance.id
}

output "nat_instance_public_ip" {
  value = aws_instance.nat_instance.public_ip
}

output "nat_instance_security_group_id" {
  value = aws_security_group.nat_instance.id
}