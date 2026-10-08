data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "nat_instance" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.nat_instance.id]
  key_name                    = var.key_name

  source_dest_check           = false
  associate_public_ip_address = true   # internet at first boot, before the EIP attaches
  user_data_replace_on_change = true   # re-run user_data when the script changes
  
  user_data = <<-EOF
    #!/bin/bash
    set -eux
    exec > >(tee /var/log/user-data.log) 2>&1

    # 1. Install iptables first (retry in case networking is slow)
    for i in $(seq 1 10); do
      dnf install -y iptables-services && break
      sleep 15
    done
    command -v iptables

    # 2. Enable IPv4 forwarding (persistent + immediate)
    echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-nat.conf
    sysctl --system

    # 3. Find the primary interface from the default route
    IFACE=""
    for i in $(seq 1 30); do
      IFACE=$(ip -o -4 route show to default | awk '{for(i=1;i<=NF;i++) if ($i=="dev") {print $(i+1); exit}}')
      [ -n "$IFACE" ] && break
      sleep 2
    done
    [ -n "$IFACE" ]

    # 4. NAT rule (idempotent)
    iptables -t nat -C POSTROUTING -o "$IFACE" -j MASQUERADE 2>/dev/null || \
      iptables -t nat -A POSTROUTING -o "$IFACE" -j MASQUERADE

    # 5. Persist and start
    iptables-save > /etc/sysconfig/iptables
    systemctl enable --now iptables
  EOF

  tags = {
    Name        = var.name
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