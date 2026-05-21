# Automated AWS Infrastructure (Terraform + GitHub Actions)

Fully automated AWS infrastructure provisioning using **Terraform** and **GitHub Actions**. Pushes to `main` automatically deploy an Nginx web server on EC2, and a manual workflow tears everything down.

## Architecture

```
┌─────────────────────────────────────────────────┐
│                     AWS (eu-central-1)          │
│                                                 │
│  ┌─────────── VPC (10.0.0.0/16) ─────────────┐ │
│  │                                             │ │
│  │  ┌──── Public Subnet (10.0.1.0/24) ─────┐  │ │
│  │  │                                       │  │ │
│  │  │   ┌─────────────────────────────┐     │  │ │
│  │  │   │   EC2 (Amazon Linux 2023)   │     │  │ │
│  │  │   │   t2.micro · Nginx          │     │  │ │
│  │  │   └─────────────────────────────┘     │  │ │
│  │  │                                       │  │ │
│  │  └───────────────────────────────────────┘  │ │
│  │                                             │ │
│  │  Internet Gateway ←→ Route Table            │ │
│  └─────────────────────────────────────────────┘ │
│                                                 │
│  Security Group: inbound 80/tcp, outbound all   │
│  S3 Backend: remote state storage               │
└─────────────────────────────────────────────────┘
```

## Resources Created

| Resource | Description |
|---|---|
| **VPC** | Custom VPC with DNS support (`10.0.0.0/16`) |
| **Subnet** | Public subnet with auto-assigned public IPs (`10.0.1.0/24`) |
| **Internet Gateway** | Enables internet access for the VPC |
| **Route Table** | Routes all traffic (`0.0.0.0/0`) through the internet gateway |
| **Security Group** | Allows inbound HTTP (port 80) and all outbound traffic |
| **EC2 Instance** | Amazon Linux 2023 (`t2.micro`) with Nginx installed via user data |

## CI/CD Workflows

### Plan & Apply (`build.yml`)

Triggered on every push to `main`. Runs `terraform init` → `plan` → `apply --auto-approve`.

### Destroy (`destroy.yml`)

Triggered manually via **workflow_dispatch**. Runs `terraform init` → `destroy --auto-approve` to tear down all resources.

## Prerequisites

- An AWS account with an S3 bucket for Terraform state (configured as `aas-storage-26` in `eu-central-1`)
- The following **GitHub repository secrets**:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`

## Variables

| Variable | Description | Default |
|---|---|---|
| `region` | AWS region | `eu-central-1` |
| `instance_type` | EC2 instance type | `t2.micro` |

## Outputs

| Output | Description |
|---|---|
| `public_ip` | Public IP address of the deployed Nginx web server |

## Project Structure

```
.
├── .github/workflows/
│   ├── build.yml           # CI/CD: plan & apply on push to main
│   └── destroy.yml         # Manual: destroy all infrastructure
├── scripts/
│   └── install_nginx.sh    # EC2 user data script
├── main.tf                 # VPC, subnet, SG, EC2 resources
├── providers.tf            # AWS provider & S3 backend config
├── variables.tf            # Input variables
├── outputs.tf              # Output definitions
└── .gitignore              # Terraform-specific ignores
```

## Tech Stack

- **Terraform** `1.15.4`
- **AWS Provider** `~> 5.0`
- **GitHub Actions** with `actions/checkout@v6`, `aws-actions/configure-aws-credentials@v6`, `hashicorp/setup-terraform@v4`
