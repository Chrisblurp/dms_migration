# Cloud Migration DevOps Project using AWS DMS, Terraform & Jenkins

A production-style cloud migration project demonstrating how legacy on-premise application data can be migrated to cloud infrastructure using AWS Database Migration Service (DMS), Infrastructure as Code, and CI/CD automation.

This project simulates a real-world enterprise migration workflow where organizations modernize applications by moving infrastructure and databases from on-premise environments to the cloud.

---

# Project Highlights

- Simulated on-premise to cloud migration
- AWS Database Migration Service (DMS)
- Infrastructure as Code with Terraform
- CI/CD automation using Jenkins
- Automated infrastructure provisioning
- Database replication workflow
- Cloud migration strategy implementation
- DevOps automation pipeline
- AWS cloud deployment

---

# Migration Architecture Overview

## Migration Workflow

```text
On-Premise Application & Database
                ↓
AWS Database Migration Service (DMS)
                ↓
Cloud Database Replication
                ↓
Terraform Infrastructure Provisioning
                ↓
Jenkins CI/CD Automation
                ↓
Application Deployment in AWS Cloud
```

---

# Tech Stack

## Cloud Services

- Amazon Web Services (AWS)
- AWS Database Migration Service (DMS)
- Amazon EC2
- Amazon RDS

## DevOps Tools

- Jenkins
- Terraform
- Docker
- GitHub

## Infrastructure as Code

- Terraform
- AWS Provider

## Development

- Linux
- Bash
- YAML

---

# Project Objectives

The goal of this project was to simulate a real enterprise cloud migration process by:

- Migrating application data from on-premise infrastructure
- Automating cloud infrastructure provisioning
- Implementing CI/CD automation
- Managing infrastructure using Terraform
- Using AWS DMS for database replication
- Deploying workloads into cloud environments

---

# Project Structure

```bash
.
├── app/
├── terraform/
├── jenkins/
├── migration/
├── scripts/
├── screenshots/
├── Dockerfile
├── Jenkinsfile
└── README.md
```

---

# Features

- Cloud migration simulation
- Automated infrastructure deployment
- AWS DMS database replication
- Jenkins CI/CD pipeline
- Terraform Infrastructure as Code
- Cloud resource automation
- Scalable deployment workflow
- Production-style migration process

---

# Prerequisites

Install and configure:

- AWS CLI
- Terraform
- Docker
- Jenkins
- Git
- AWS Account

---

# Clone Repository

```bash
git clone https://github.com/Chrisblurp/Blood-Donor-App.git

cd cloud-migration-devops-project
```

---

# AWS Configuration

Configure AWS credentials:

```bash
aws configure
```

Provide:

- AWS Access Key
- AWS Secret Key
- Default Region
- Output Format

---

# Infrastructure Provisioning with Terraform

Terraform was used to provision AWS cloud infrastructure required for the migration environment.

---

# Terraform Workflow

## Initialize Terraform

```bash
cd terraform

terraform init
```

---

# Review Infrastructure Plan

```bash
terraform plan
```

---

# Provision Infrastructure

```bash
terraform apply
```

---

# Infrastructure Components

Terraform provisions:

- EC2 instances
- Networking resources
- Security groups
- Database infrastructure
- Migration resources

---

# AWS Database Migration Service (DMS)

AWS DMS was used to migrate and replicate data from the simulated on-premise database to AWS cloud infrastructure.

---

# Migration Workflow

The migration process included:

1. Source database configuration
2. Target cloud database setup
3. Replication instance creation
4. DMS migration task configuration
5. Continuous replication monitoring

---

# AWS DMS Features Used

- Full load migration
- Continuous replication
- Minimal downtime migration
- Migration monitoring

---

# Jenkins CI/CD Pipeline

Jenkins was used to automate:

- Infrastructure deployment
- Application build processes
- Migration workflow execution
- Automated deployment tasks

---

# Jenkins Pipeline Workflow

```text
Code Commit
      ↓
Jenkins Pipeline Trigger
      ↓
Terraform Infrastructure Deployment
      ↓
AWS DMS Migration Execution
      ↓
Application Deployment
      ↓
Verification & Monitoring
```

---

# Run Jenkins in Docker

```bash
docker run -d \
--name jenkins \
-p 8080:8080 \
-p 50000:50000 \
-v jenkins_home:/var/jenkins_home \
jenkins/jenkins:lts
```

---

# Access Jenkins

Open browser:

```text
http://localhost:8080
```

---

# CI/CD Features

- Automated deployments
- Infrastructure automation
- Continuous integration
- Continuous delivery
- Migration workflow orchestration

---

# Application Deployment

After infrastructure provisioning and migration:

- Deploy application workloads
- Verify cloud connectivity
- Confirm migrated database access
- Validate application functionality

---

# Monitoring & Validation

The migration workflow includes:

- Migration status checks
- Database replication monitoring
- Infrastructure validation
- Deployment verification

---

# DevOps Skills Demonstrated

- AWS cloud infrastructure
- AWS DMS migration workflows
- Terraform Infrastructure as Code
- Jenkins CI/CD automation
- Cloud migration strategy
- Infrastructure provisioning
- Database replication
- DevOps pipeline implementation
- Linux administration
- Automation scripting


---

# Lessons Learned

Through this project, I gained hands-on experience with:

- Migrating workloads from on-premise to cloud
- Using AWS DMS for database migration
- Automating infrastructure provisioning
- Building Jenkins automation pipelines
- Managing Infrastructure as Code
- Monitoring migration workflows
- Designing cloud migration strategies
- Working with production-style cloud environments

---

# Future Improvements

- Multi-region migration support
- Blue/Green migration strategy
- Automated rollback process
- Kubernetes-based deployment
- Monitoring integration with Prometheus & Grafana
- GitOps deployment workflow
- Database backup automation

---

