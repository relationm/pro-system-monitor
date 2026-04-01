# terraform/main.tf

# 1. Define the Cloud Provider
provider "aws" {
  region = "eu-central-1" # Frankfurt region
}

# 2. Resource to upload your Public SSH Key to AWS
# This allows Ansible and you to log in without a password
resource "aws_key_pair" "monitor_ssh_key" {
  key_name   = "monitoring-server-key"
  public_key = file("./monitor_key.pub") # Path to your local public key
}

# 3. Create Firewall (Security Group) for the server
resource "aws_security_group" "monitor_sg" {
  name        = "system_monitor_sg"
  description = "Security group for System Monitor API and SSH"

  # Rule: SSH Access (Port 22) - Required for Ansible configuration
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open for setup; restrict to your IP for better security
  }

  # Rule: API Access (Port 8000) - For remote agents to send metrics
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Agents can be located anywhere on the internet
  }

  # Rule: Outbound traffic - Allows the server to download Docker, Updates, and Images
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. Create the EC2 Instance (The actual Virtual Machine)
resource "aws_instance" "monitoring_core" {
  ami           = "ami-0faab6bdbac9486fb" # Ubuntu 22.04 LTS in eu-central-1
  instance_type = "t3.micro"             # Free Tier eligible

  # Link the Security Group we created above
  vpc_security_group_ids = [aws_security_group.monitor_sg.id]

  # Link the SSH Key Pair for access
  key_name = aws_key_pair.monitor_ssh_key.key_name

# 2GB Swap
  user_data = <<-EOF
              #!/bin/bash
              fallocate -l 2G /swapfile
              chmod 600 /swapfile
              mkswap /swapfile
              swapon /swapfile
              echo '/swapfile none swap sw 0 0' >> /etc/fstab
              EOF

  tags = {
    Name = "System-Monitor-Core"
    Project = "Pet-Monitoring"
  }

  # Root block device configuration (SSD settings)
  root_block_device {
    volume_size = 10 # 10 GB is enough for a small monitoring DB
    volume_type = "gp3"
  }
}

# 5. Output the Public IP address after creation
# We will need this IP for our Ansible Inventory file
output "server_public_ip" {
  value = aws_instance.monitoring_core.public_ip
}