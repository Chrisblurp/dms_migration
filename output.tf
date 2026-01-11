########################################
# Outputs
########################################

# VPC Information
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_a_id" {
  description = "Private Subnet A ID"
  value       = aws_subnet.private_a.id
}

output "private_subnet_b_id" {
  description = "Private Subnet B ID"
  value       = aws_subnet.private_b.id
}

# Bastion Instance
output "bastion_instance_id" {
  description = "Bastion EC2 instance ID"
  value       = aws_instance.bastion.id
}

output "bastion_private_ip" {
  description = "Bastion private IP address"
  value       = aws_instance.bastion.private_ip
}

output "bastion_connection_command" {
  description = "Command to connect to bastion via SSM"
  value       = "aws ssm start-session --target ${aws_instance.bastion.id} --region eu-central-1"
}

# RDS Endpoints
output "source_rds_endpoint" {
  description = "Source RDS endpoint"
  value       = aws_db_instance.source.address
}

output "source_rds_port" {
  description = "Source RDS port"
  value       = aws_db_instance.source.port
}

output "target_rds_endpoint" {
  description = "Target RDS endpoint"
  value       = aws_db_instance.target.address
}

output "target_rds_port" {
  description = "Target RDS port"
  value       = aws_db_instance.target.port
}

output "source_mysql_command" {
  description = "MySQL command to connect to source database"
  value       = "mysql -h ${split(":", aws_db_instance.source.address)[0]} -P 3306 -u admin -p sourcedb"
}

output "target_mysql_command" {
  description = "MySQL command to connect to target database"
  value       = "mysql -h ${split(":", aws_db_instance.target.address)[0]} -P 3306 -u admin -p targetdb"
}

# VPC Endpoints
output "vpc_endpoints" {
  description = "VPC Endpoint IDs"
  value = {
    ssm         = aws_vpc_endpoint.ssm.id
    ssmmessages = aws_vpc_endpoint.ssmmessages.id
    ec2messages = aws_vpc_endpoint.ec2messages.id
    logs        = aws_vpc_endpoint.logs.id
  }
}

output "vpc_endpoint_dns_entries" {
  description = "VPC Endpoint DNS entries"
  value = {
    ssm         = aws_vpc_endpoint.ssm.dns_entry
    ssmmessages = aws_vpc_endpoint.ssmmessages.dns_entry
    ec2messages = aws_vpc_endpoint.ec2messages.dns_entry
    logs        = aws_vpc_endpoint.logs.dns_entry
  }
}

# DMS Resources
output "dms_replication_instance_arn" {
  description = "DMS replication instance ARN"
  value       = aws_dms_replication_instance.this.replication_instance_arn
}

output "dms_replication_instance_private_ip" {
  description = "DMS replication instance private IP"
  value       = aws_dms_replication_instance.this.replication_instance_private_ips
}

output "dms_source_endpoint_arn" {
  description = "DMS source endpoint ARN"
  value       = aws_dms_endpoint.source.endpoint_arn
}

output "dms_target_endpoint_arn" {
  description = "DMS target endpoint ARN"
  value       = aws_dms_endpoint.target.endpoint_arn
}

output "dms_replication_task_arn" {
  description = "DMS replication task ARN"
  value       = aws_dms_replication_task.this.replication_task_arn
}

# Security Groups
output "bastion_security_group_id" {
  description = "Bastion security group ID"
  value       = aws_security_group.bastion_sg.id
}

output "db_security_group_id" {
  description = "Database security group ID"
  value       = aws_security_group.db.id
}

output "dms_security_group_id" {
  description = "DMS security group ID"
  value       = aws_security_group.dms.id
}

output "vpc_endpoints_security_group_id" {
  description = "VPC endpoints security group ID"
  value       = aws_security_group.vpc_endpoints_sg.id
}

# Quick Start Commands
output "quick_start_commands" {
  description = "Quick start commands for testing"
  value       = <<-EOT
    # 1. Connect to bastion via SSM
    aws ssm start-session --target ${aws_instance.bastion.id} --region eu-central-1
    
    # 2. Once connected, test source database
    mysql -h ${split(":", aws_db_instance.source.address)[0]} -u admin -p sourcedb
    # Password: Admin12345!
    
    # 3. Test target database
    mysql -h ${split(":", aws_db_instance.target.address)[0]} -u admin -p targetdb
    # Password: Admin12345!
    
    # 4. Check DMS replication task status
    aws dms describe-replication-tasks \
      --filters "Name=replication-task-arn,Values=${aws_dms_replication_task.this.replication_task_arn}" \
      --region eu-central-1
    
    # 5. Start DMS replication task
    aws dms start-replication-task \
      --replication-task-arn ${aws_dms_replication_task.this.replication_task_arn} \
      --start-replication-task-type start-replication \
      --region eu-central-1
  EOT
}

# Verification Commands
output "verification_commands" {
  description = "Commands to verify the setup"
  value       = <<-EOT
    # Check VPC DNS settings
    aws ec2 describe-vpc-attribute --vpc-id ${aws_vpc.main.id} --attribute enableDnsHostnames
    aws ec2 describe-vpc-attribute --vpc-id ${aws_vpc.main.id} --attribute enableDnsSupport
    
    # Check VPC endpoints status
    aws ec2 describe-vpc-endpoints \
      --filters "Name=vpc-id,Values=${aws_vpc.main.id}" \
      --query 'VpcEndpoints[*].[ServiceName,State,PrivateDnsEnabled]' \
      --output table
    
    # Check SSM agent status
    aws ssm describe-instance-information \
      --filters "Key=InstanceIds,Values=${aws_instance.bastion.id}" \
      --region eu-central-1 \
      --output table
    
    # Check RDS instances
    aws rds describe-db-instances \
      --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Endpoint.Address]' \
      --output table
    
    # Check DMS replication instance
    aws dms describe-replication-instances \
      --filters "Name=replication-instance-id,Values=dms-lab-instance" \
      --region eu-central-1 \
      --output table
  EOT
}