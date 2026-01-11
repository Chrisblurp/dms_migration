########################################
# IAM Role for SSM Session Manager
########################################

resource "aws_iam_role" "ssm_role" {
  name = "bastion-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "bastion-ssm-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "bastion-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

########################################
# Bastion security group
########################################

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Bastion SG (private, SSM only)"
  vpc_id      = aws_vpc.main.id

  # Allow outbound HTTPS to VPC endpoints
  egress {
    description = "HTTPS to VPC endpoints"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  # Allow outbound MySQL to RDS
  egress {
    description = "MySQL to RDS"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  # Allow all other outbound traffic
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-security-group"
  }
}

########################################
# Allow bastion -> RDS on 3306
########################################

resource "aws_security_group_rule" "allow_bastion_to_rds" {
  type                     = "ingress"
  description              = "MySQL from bastion"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.bastion_sg.id
}

########################################
# Bastion EC2 instance (private only)
########################################

resource "aws_instance" "bastion" {
  ami                         = "ami-0f2367292005b3bad" # Amazon Linux 2023
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private_a.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name

  depends_on = [
    aws_vpc_endpoint.ssm,
    aws_vpc_endpoint.ssmmessages,
    aws_vpc_endpoint.ec2messages,
    aws_vpc_endpoint.logs
  ]

  user_data = <<-EOF
              #!/bin/bash
              set -xe
              
              # Update system
              dnf update -y
              
              # Install and configure SSM Agent (should be pre-installed on AL2023)
              dnf install -y amazon-ssm-agent
              systemctl enable amazon-ssm-agent
              systemctl restart amazon-ssm-agent
              
              # Install MySQL client
              dnf install -y mariadb105
              
              # Wait for SSM to register
              sleep 30
              
              # Log SSM status
              systemctl status amazon-ssm-agent > /var/log/ssm-status.log
              
              # Test DNS resolution for endpoints
              nslookup ssm.eu-central-1.amazonaws.com >> /var/log/ssm-status.log
              nslookup ssmmessages.eu-central-1.amazonaws.com >> /var/log/ssm-status.log
              nslookup ec2messages.eu-central-1.amazonaws.com >> /var/log/ssm-status.log
              EOF

  tags = {
    Name = "dms-bastion-private"
  }
}