data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "nat_instance" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = "t3.nano"
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.nat_instance.id]

  key_name = var.key_name

  source_dest_check = false
  
  user_data = <<-EOF
    #!/bin/bash
    set -eux

    # Install iptables persistence support
    dnf install -y iptables-services

    # Enable IPv4 forwarding permanently
    cat > /etc/sysctl.d/99-nat.conf <<'SYSCTL'
    net.ipv4.ip_forward = 1
    SYSCTL

    sysctl --system

    # Detect the primary network interface
    IFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}')

    # Configure NAT / masquerading
    iptables -t nat -A POSTROUTING -o "$IFACE" -j MASQUERADE

    # Persist firewall rules
    iptables-save > /etc/sysconfig/iptables

    systemctl enable iptables
    systemctl start iptables
  EOF

  tags = {
    Name        = "${var.name}"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = var.managed_by
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "${var.name}-eip"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = var.managed_by
  }
}

resource "aws_eip_association" "nat" {
  instance_id   = aws_instance.nat_instance.id
  allocation_id = aws_eip.nat.id
}