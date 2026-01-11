# vpc and subnets
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true  # CRITICAL for VPC endpoints
  enable_dns_support   = true  # CRITICAL for VPC endpoints

  tags = {
    Name = "dms-vpc"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "dms-private-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "dms-private-b"
  }
}

# dms vpc roles
resource "aws_iam_role" "dms_vpc_role" {
  name = "dms-vpc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "dms.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "dms-vpc-role"
  }
}

# DMS Cloudwatch Roles
resource "aws_iam_role" "dms_cloudwatch_logs_role" {
  name = "dms-cloudwatch-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "dms.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "dms-cloudwatch-logs-role"
  }
}

resource "aws_iam_role_policy_attachment" "dms_cloudwatch_logs_policy" {
  role       = aws_iam_role.dms_cloudwatch_logs_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
}

resource "aws_iam_role_policy_attachment" "dms_vpc_role_policy" {
  role       = aws_iam_role.dms_vpc_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}

# db resource def => ingress & egress
resource "aws_security_group" "db" {
  name        = "db-sg"
  description = "Security group for RDS databases"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from DMS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.dms.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    ignore_changes = [
      name,
      description,
      tags,
      ingress,
      egress
    ]
  }

  tags = {
    Name = "db-security-group"
  }
}

resource "aws_security_group" "dms" {
  name        = "dms-sg"
  description = "Security group for DMS replication instance"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    ignore_changes = [
      name,
      description,
      tags,
      egress
    ]
  }

  tags = {
    Name = "dms-security-group"
  }
}

# source and target groups
resource "aws_db_subnet_group" "db" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "db-subnet-group"
  }
}

resource "aws_db_instance" "source" {
  identifier        = "source-db"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t4g.micro"

  allocated_storage = 20

  username = "admin"
  password = "Admin12345!" # use AWS Secrets Manager in production
  db_name  = "sourcedb"

  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.db.name
  skip_final_snapshot    = true
  
  # Enable binary logging for CDC
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
  backup_retention_period         = 1

  tags = {
    Name = "source-rds"
  }
}

resource "aws_db_instance" "target" {
  identifier        = "target-db"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t4g.micro"
  allocated_storage = 20

  username = "admin"
  password = "Admin12345!" # use AWS Secrets Manager in production
  db_name  = "targetdb"

  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.db.name
  skip_final_snapshot    = true

  tags = {
    Name = "target-rds"
  }
}

# DMS Replication subnet group
resource "aws_dms_replication_subnet_group" "this" {
  replication_subnet_group_id          = "dms-subnet-group"
  replication_subnet_group_description = "DMS subnet group"
  subnet_ids                           = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "dms-subnet-group"
  }
}

# DMS Replication instance
resource "aws_dms_replication_instance" "this" {
  replication_instance_id       = "dms-lab-instance"
  replication_instance_class    = "dms.t3.micro"
  allocated_storage             = 50
  vpc_security_group_ids        = [aws_security_group.dms.id]
  replication_subnet_group_id   = aws_dms_replication_subnet_group.this.replication_subnet_group_id
  publicly_accessible           = false
  multi_az                      = false
  apply_immediately             = true

  tags = {
    Name = "dms-replication-instance"
  }
}

# DMS Endpoints Instances
resource "aws_dms_endpoint" "source" {
  endpoint_id   = "source-endpoint"
  endpoint_type = "source"
  engine_name   = "mysql"

  username      = aws_db_instance.source.username
  password      = aws_db_instance.source.password
  port          = 3306
  server_name   = aws_db_instance.source.address
  database_name = aws_db_instance.source.db_name

  ssl_mode = "none"

  tags = {
    Name = "source-endpoint"
  }
}

resource "aws_dms_endpoint" "target" {
  endpoint_id   = "target-endpoint"
  endpoint_type = "target"
  engine_name   = "mysql"

  username      = aws_db_instance.target.username
  password      = aws_db_instance.target.password
  port          = 3306
  server_name   = aws_db_instance.target.address
  database_name = aws_db_instance.target.db_name

  ssl_mode = "none"

  tags = {
    Name = "target-endpoint"
  }
}

# DMS Replication Task (Full Load + CDC)
resource "aws_dms_replication_task" "this" {
  replication_task_id      = "lab-fullload-and-cdc"
  migration_type           = "full-load-and-cdc"
  replication_instance_arn = aws_dms_replication_instance.this.replication_instance_arn
  source_endpoint_arn      = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.target.endpoint_arn
  
  table_mappings = jsonencode({
    rules = [
      {
        rule-type = "selection"
        rule-id   = "1"
        rule-name = "include-all-tables"
        object-locator = {
          schema-name = "%"
          table-name  = "%"
        }
        rule-action = "include"
      }
    ]
  })

  replication_task_settings = jsonencode({
    TargetMetadata = {
      TargetSchema            = ""
      SupportLobs             = true
      FullLobMode             = false
      LobChunkSize            = 64
      ParallelApplyThreads    = 0
      ParallelApplyBufferSize = 0
    }
    FullLoadSettings = {
      TargetTablePrepMode = "DROP_AND_CREATE"
      StopOnError         = true
      MaxFullLoadSubTasks = 8
    }
    Logging = {
      EnableLogging = true
      LogComponents = [
        { Id = "SOURCE_UNLOAD", Severity = "LOGGER_SEVERITY_DEFAULT" },
        { Id = "TARGET_LOAD",   Severity = "LOGGER_SEVERITY_DEFAULT" },
        { Id = "TASK_MANAGER",  Severity = "LOGGER_SEVERITY_DEFAULT" }
      ]
    }
    ControlTablesSettings = {
      ControlSchema = ""
    }
  })
}