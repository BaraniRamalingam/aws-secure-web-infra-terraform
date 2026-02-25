# AWS Secure Web Infrastructure using Terraform

This project provisions a secure, production-style web application infrastructure on AWS using Terraform.

All infrastructure is provisioned using modular Terraform code to ensure repeatability, maintainability, and environment consistency. The implementation follows a layered architecture approach to isolate the public access layer from the compute layer.

---

## Solution Overview

The infrastructure consists of:

- Custom VPC
- Multi-AZ public subnets
- Internet Gateway and routing
- Application Load Balancer (ALB)
- Target Group with health checks
- EC2 instance running Nginx
- IAM role for secure Systems Manager (SSM) access

### Traffic Flow

Client (Internet)  

→ Application Load Balancer (public)  
→ Target Group  
→ EC2 instance  
→ Nginx web server 

The EC2 instance is not publicly exposed. All inbound traffic is routed through the ALB.

---

## Security Architecture

Security was implemented with layered controls:

- EC2 security group allows inbound traffic only from the ALB security group
- No direct public HTTP access to EC2
- No SSH access (port 22 not exposed)
- Administrative access via AWS Systems Manager (Session Manager)
- Security group-based service-to-service access control enforced between ALB and EC2.
- Health checks configured at the load balancer level

This design enforces separation between the public entry point and the compute layer.

---

## Infrastructure Design Principles

- Modular Terraform architecture
- Reusable VPC, EC2, and ALB modules
- Environment-based structure (envs/dev)
- Infrastructure lifecycle managed via Terraform
- Designed with cost-efficiency considerations while maintaining production-aligned architecture.

---

## Project Structure
```
aws-secure-web-infra-terraform/
|
|-- modules/
|     |--- vpc/
|     |--- ec2-web/
|     |--- alb/
|
|-- envs/
|     |--- dev/
|
|-- docs/
      |--- screenshots
```

Each module is independently reusable and parameterized.

---

## Deployment

Initialize and deploy:

```
cd envs/dev
terraform init
terraform plan
terraform apply
```

After deployment, retrieve the application endpoint:

```
terraform output alb_url
```
---

## Teardown

To prevent unnecessary AWS charges:
```
cd envs/dev
terraform destroy
```

---

## Key Implementation Highlights

- ALB-based web tier architecture
- Secure EC2 access via security group referencing
- SSM-based administration (no SSH keys required)
- Automated Nginx provisioning via user_data
- Health-checked target group attachment
- Infrastructure reproducibility through code

---

## Validation

Screenshots in `/docs/screenshots` demonstrate:

- ALB configuration
- Healthy target group status
- Restricted EC2 security group
- Successful Nginx response
- Terraform output verification

