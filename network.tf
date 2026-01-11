
########################################
# VPC Endpoint Security Group
########################################

resource "aws_security_group" "vpc_endpoints_sg" {
  name        = "vpc-endpoints-sg"
  description = "Security group for VPC interface endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-endpoints-sg"
  }
}

########################################
# Allow Bastion → VPC Endpoints
########################################

resource "aws_security_group_rule" "vpce_allow_bastion" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpc_endpoints_sg.id
  source_security_group_id = aws_security_group.bastion_sg.id
  description              = "Allow bastion to reach VPC endpoints"
}

########################################
# SSM VPC Endpoints (Required for SSM Agent)
###########aa#############################

resource "aws_vpc_endpoint" "ssm" {
  depends_on = [aws_vpc.main]

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.eu-central-1.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
  security_group_ids  = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "ssm-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  depends_on = [aws_vpc.main]

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.eu-central-1.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
  security_group_ids  = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "ssmmessages-endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  depends_on = [aws_vpc.main]

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.eu-central-1.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
  security_group_ids  = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "ec2messages-endpoint"
  }
}


# s3 endpoint to install packages to instances 
resource "aws_vpc_endpoint" "s3" {


  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"

  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_vpc.main.default_route_table_id
  ]

  tags = {
    Name = "s3-endpoint"
  }
}
########################################
# Optional but Recommended: CloudWatch Logs Endpoint
########################################

resource "aws_vpc_endpoint" "logs" {
  depends_on = [aws_vpc.main]

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.eu-central-1.logs"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
  security_group_ids  = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "logs-endpoint"
  }
}