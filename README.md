# 🚀 TERRAFORM COMPLETE REVISION GUIDE (2025)

## 📑 TABLE OF CONTENTS
1. [Terraform Basics](#1-terraform-basics)
2. [Installation & Setup](#2-installation--setup)
3. [Core Commands](#3-core-commands)
4. [Configuration Files](#4-configuration-files)
5. [Variables](#5-variables)
6. [Workspaces](#6-workspaces)
7. [State Management](#7-state-management)
8. [Outputs](#8-outputs)
9. [Locals](#9-locals)
10. [Backends (S3)](#10-backends-s3)
11. [Taint & Replace](#11-taint--replace)
12. [Lifecycle Meta Arguments](#12-lifecycle-meta-arguments)
13. [Providers & Aliases](#13-providers--aliases)
14. [Import](#14-import)
15. [Version Constraints](#15-version-constraints)
16. [Dynamic Blocks & for_each](#16-dynamic-blocks--for_each)
17. [State Commands Reference](#17-state-commands-reference)
18. [Quick Command Reference](#18-quick-command-reference)
19. [Best Practices](#19-best-practices)
20. [Common Patterns](#20-common-patterns)

---

## 1. TERRAFORM BASICS

### What is Terraform?
- **Infrastructure as Code (IaaC)** tool
- Automates infrastructure provisioning
- Uses **HCL** (HashiCorp Configuration Language)
- **Platform-independent** (AWS, Azure, GCP, on-premises)

### Key Advantages
```
✅ Reusable code
✅ Time-saving automation
✅ Eliminates manual errors
✅ Dry run capability (plan)
✅ Version control infrastructure
```

### Terraform vs Competitors
| Tool | Platform |
|------|----------|
| CloudFormation (CFT) | AWS only |
| ARM Templates | Azure only |
| Deployment Manager | GCP only |
| **Terraform** | **All clouds + on-prem** |

### Core Workflow
```
Code (HCL) → Plan → Apply → Infrastructure Created
```

---

## 2. INSTALLATION & SETUP

### Install Terraform (Amazon Linux)
```bash
sudo yum install -y yum-utils shadow-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
```

### Configure AWS
```bash
aws configure
# Enter: Access Key, Secret Key, Region, Output format
```

### Create Working Directory
```bash
mkdir terraform
cd terraform
```

### Verify Installation
```bash
terraform version
```

---

## 3. CORE COMMANDS

### Essential Commands

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `terraform init` | Initialize providers | First command in new directory |
| `terraform plan` | Preview changes | Before applying |
| `terraform apply` | Create/update resources | Deploy infrastructure |
| `terraform destroy` | Delete all resources | Cleanup |
| `terraform validate` | Check syntax | After editing files |
| `terraform fmt` | Format code | Before committing |
| `terraform refresh` | Sync state with reality | After manual changes |

### Command Flags
```bash
# Auto-approve (skip confirmation)
terraform apply --auto-approve
terraform destroy --auto-approve

# Use specific variable file
terraform apply -var-file="dev.tfvar"

# Target specific resource
terraform destroy -target="aws_instance.web"

# Multiple targets
terraform destroy -target="aws_instance.web" -target="aws_instance.app"

# Replace specific resource (modern way to force recreation)
terraform apply -replace="aws_instance.web"
```

### Initialization
```bash
terraform init              # First time setup
terraform init -upgrade     # Upgrade providers
terraform init -migrate-state  # Migrate to new backend
```

---

## 4. CONFIGURATION FILES

### File Structure
```
terraform/
├── main.tf           # Main configuration
├── variable.tf       # Variable declarations
├── outputs.tf        # Output definitions
├── dev.tfvar         # Dev environment values
├── test.tfvar        # Test environment values
├── prod.tfvar        # Prod environment values
└── terraform.tfstate # State file (auto-generated)
```

### Basic Resource Syntax
```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-079db87dc4c10ac91"
  instance_type = "t2.micro"
  
  tags = {
    Name = "web-server"
  }
}
```

### Multiple Resources
```hcl
# Create 5 instances
resource "aws_instance" "servers" {
  count         = 5
  ami           = "ami-079db87dc4c10ac91"
  instance_type = "t2.micro"
  
  tags = {
    Name = "server-${count.index}"
  }
}
```

---

## 5. VARIABLES

### Variable Declaration (variable.tf)
```hcl
variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 3
}

variable "ami_id" {
  type    = string
  default = "ami-079db87dc4c10ac91"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "instance_names" {
  type    = list(string)
  default = ["web", "app", "db"]
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

### Variable Types
- `string` - Text
- `number` - Numeric values
- `bool` - true/false
- `list` - Ordered collection
- `map` - Key-value pairs
- `set` - Unique values
- `object` - Complex structure

### Using Variables
```hcl
resource "aws_instance" "web" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  
  tags = var.tags
}
```

### TFVARS Files

**variable.tf** (declarations only)
```hcl
variable "instance_count" {}
variable "ami_id" {}
variable "instance_type" {}
```

**dev.tfvar** (dev values)
```hcl
instance_count = 1
ami_id         = "ami-079db87dc4c10ac91"
instance_type  = "t2.micro"
```

**prod.tfvar** (prod values)
```hcl
instance_count = 5
ami_id         = "ami-0c02fb55956c7d316"
instance_type  = "t2.large"
```

**Usage:**
```bash
terraform apply -var-file="dev.tfvar"
terraform apply -var-file="prod.tfvar"
```

---

## 6. WORKSPACES

### Purpose
Create isolated environments (dev, test, prod) with same configuration

### Why Use Workspaces?
```
❌ Problem: Single workspace overrides previous deployment
✅ Solution: Multiple workspaces run in parallel
```

### Workspace Commands

| Command | Purpose |
|---------|---------|
| `terraform workspace list` | Show all workspaces |
| `terraform workspace new dev` | Create workspace |
| `terraform workspace select dev` | Switch workspace |
| `terraform workspace show` | Current workspace |
| `terraform workspace delete dev` | Delete workspace |

### Workspace Rules
1. **Must be empty** before deletion (destroy first)
2. **Cannot delete** current workspace (switch first)
3. **Cannot delete** default workspace (permanent)

### Workflow Example
```bash
# Create workspaces
terraform workspace new dev
terraform workspace new test
terraform workspace new prod

# Deploy dev
terraform workspace select dev
terraform apply -var-file="dev.tfvar"

# Deploy test
terraform workspace select test
terraform apply -var-file="test.tfvar"

# Deploy prod
terraform workspace select prod
terraform apply -var-file="prod.tfvar"

# Result: All 3 environments exist simultaneously
```

### Using Workspace Name in Code
```hcl
locals {
  env = terraform.workspace  # Returns: dev, test, or prod
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  tags = {
    Name = "${local.env}-web-server"  # dev-web-server, test-web-server, etc.
  }
}
```

---

## 7. STATE MANAGEMENT

### State File (terraform.tfstate)
- **Tracks** all resources created by Terraform
- **Maps** configuration to real infrastructure
- **Critical** - losing it means losing tracking

### State File Location
```
# Local (default)
./terraform.tfstate

# With workspaces
./terraform.tfstate.d/
  ├── dev/terraform.tfstate
  ├── test/terraform.tfstate
  └── prod/terraform.tfstate
```

### State Commands

```bash
# List resources in state
terraform state list

# Show specific resource
terraform state show aws_instance.web

# Rename resource (no recreation)
terraform state mv aws_instance.old aws_instance.new

# Remove from state (resource remains in AWS)
terraform state rm aws_instance.legacy

# Pull remote state to stdout
terraform state pull

# Push local state to backend (DANGEROUS)
terraform state push terraform.tfstate
```

### State Refresh
```bash
# Sync state with actual infrastructure
terraform refresh

# Use case: Manual changes made in AWS console
```

---

## 8. OUTPUTS

### Purpose
Display specific resource information after creation

### Output Block Syntax
```hcl
output "instance_public_ip" {
  description = "Public IP of web server"
  value       = aws_instance.web.public_ip
}

output "instance_private_ip" {
  value = aws_instance.web.private_ip
}

output "instance_dns" {
  value = aws_instance.web.public_dns
}

# Multiple values
output "server_info" {
  value = {
    public_ip  = aws_instance.web.public_ip
    private_ip = aws_instance.web.private_ip
    instance_id = aws_instance.web.id
  }
}

# Array of values
output "all_ips" {
  value = [
    aws_instance.web[0].public_ip,
    aws_instance.web[0].private_ip,
    aws_instance.web[0].public_dns
  ]
}
```

### Common Output Attributes
- `.id` - Resource ID
- `.arn` - Amazon Resource Name
- `.public_ip` - Public IP address
- `.private_ip` - Private IP address
- `.public_dns` - Public DNS name

### View Outputs
```bash
terraform output                    # Show all outputs
terraform output instance_public_ip # Show specific output
```

---

## 9. LOCALS

### Purpose
Define values once, reuse multiple times

### Local Block Syntax
```hcl
locals {
  env         = terraform.workspace
  region      = "us-east-1"
  app_name    = "myapp"
  
  common_tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
    Project     = local.app_name
  }
}
```

### Using Locals
```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = merge(local.common_tags, {
    Name = "${local.env}-vpc"
  })
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  tags = merge(local.common_tags, {
    Name = "${local.env}-public-subnet"
  })
}

resource "aws_instance" "web" {
  ami           = "ami-079db87dc4c10ac91"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  
  tags = merge(local.common_tags, {
    Name = "${local.env}-web-server"
  })
}
```

### Locals vs Variables
- **Variables:** Input from users
- **Locals:** Computed/derived values

---

## 10. BACKENDS (S3)

### Purpose
Store state file remotely for team collaboration and safety

### Why Remote Backend?
```
✅ Team collaboration
✅ State file backup
✅ Version history
✅ Locking (prevent conflicts)
✅ Encryption
```

### Modern S3 Backend Configuration (2025)

**⚡ NEW: Native State Locking with use_lockfile**

```hcl
terraform {
  backend "s3" {
    bucket       = "my-terraform-state-bucket"
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true  # ⭐ NEW: Native S3 locking (no DynamoDB needed!)
  }
}
```

### What is use_lockfile = true?

**Old Way (Pre-Terraform 1.10):**
- Required a separate DynamoDB table for state locking
- Extra infrastructure to manage and pay for
- More complex configuration

**New Way (Terraform 1.10+ / 2025):**
- Native state locking directly in S3
- No DynamoDB table needed
- Uses temporary `.tflock` files in the bucket
- Atomic operations via conditional writes
- Simpler configuration, lower cost

### Benefits of Native Locking
```
✅ No extra infrastructure (no DynamoDB)
✅ Simplified configuration (one parameter)
✅ Lower costs
✅ Atomic operations built-in
✅ Automatic cleanup of lock files
```

### Legacy S3 Backend (with DynamoDB)
```hcl
# ⚠️ DEPRECATED: Only use if on Terraform < 1.10
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"  # Old method
  }
}
```

### Setup Process (Modern Method)
```bash
# Step 1: Create S3 bucket (one-time)
aws s3 mb s3://my-terraform-state-bucket

# Step 2: Enable versioning (recommended)
aws s3api put-bucket-versioning \
  --bucket my-terraform-state-bucket \
  --versioning-configuration Status=Enabled

# Step 3: Add backend config to main.tf with use_lockfile = true

# Step 4: Initialize backend
terraform init -migrate-state
```

### Version Requirements
- **Terraform 1.10+**: use_lockfile available (experimental)
- **Terraform 1.11+**: use_lockfile recommended (stable)
- **Terraform < 1.10**: Must use DynamoDB method

### Migration from DynamoDB to Native Locking
```bash
# Step 1: Update backend configuration
# Change from dynamodb_table to use_lockfile = true

# Step 2: Reinitialize
terraform init -migrate-state

# Step 3: (Optional) Delete DynamoDB table after verification
aws dynamodb delete-table --table-name terraform-locks
```

---

## 11. TAINT & REPLACE

### ⚠️ IMPORTANT: terraform taint is DEPRECATED (2025)

**Status:** Deprecated since Terraform 0.15.2  
**Recommendation:** Use `-replace` flag instead

### What is Taint/Replace?
Mark specific resources for recreation (destroy + recreate)

### When to Use
- Resource crashed/corrupted
- Need to force replacement
- Testing resource recreation
- Configuration drift issues

### How Taint Works
1. **Marking:** `terraform taint` flags resource in state file as "tainted"
2. **Planning:** `terraform plan` schedules tainted resource for replacement
3. **Applying:** `terraform apply` destroys and recreates the resource

**⚠️ Important:** The taint command itself does NOT immediately touch infrastructure - it only modifies the state file.

### Modern Method: -replace Flag (RECOMMENDED ✅)

```bash
# Replace resource in single command
terraform apply -replace="aws_instance.web"

# Plan with replace
terraform plan -replace="aws_instance.web"

# Replace multiple resources
terraform apply -replace="aws_instance.web" -replace="aws_instance.app"
```

**Why use -replace?**
```
✅ Single-step operation (no state modification)
✅ Explicit and immediate
✅ No "ticking time bombs" in state
✅ Safer for team environments
✅ Modern best practice
```

### Legacy Method: terraform taint (DEPRECATED ⚠️)

```bash
# List resources
terraform state list

# Mark for recreation (DEPRECATED)
terraform taint aws_instance.web

# View plan (shows replacement)
terraform plan

# Apply changes (recreates tainted resource only)
terraform apply --auto-approve

# Undo taint (if needed)
terraform untaint aws_instance.web
```

### Comparison: taint vs -replace

| Feature | terraform taint (OLD) | -replace flag (NEW) |
|---------|----------------------|---------------------|
| **Status** | Deprecated | Recommended |
| **Steps** | 2-step (taint → apply) | 1-step |
| **State modification** | Yes (permanent mark) | No (temporary) |
| **Team safety** | Risk of accidental replacement | Explicit intent |
| **Terraform version** | < 1.5 | 1.5+ |

### Example Scenario
```bash
# ❌ OLD WAY (Deprecated)
terraform taint aws_instance.web
terraform apply

# ✅ NEW WAY (Recommended)
terraform apply -replace="aws_instance.web"

# Result: EC2 instance is destroyed and recreated
# Other resources remain unchanged
```

### Undo Accidental Taint
```bash
# If you accidentally tainted (old method)
terraform untaint aws_instance.web

# With -replace, no undo needed (explicit in command)
```

---

## 12. LIFECYCLE META ARGUMENTS

### 1. prevent_destroy
**Purpose:** Protect from accidental deletion

```hcl
resource "aws_db_instance" "production" {
  # ... configuration ...
  
  lifecycle {
    prevent_destroy = true  # Cannot be destroyed
  }
}
```

**Behavior:**
- `terraform destroy` will **fail**
- Must change to `false` to delete

### 2. ignore_changes
**Purpose:** Ignore manual changes made outside Terraform

```hcl
resource "aws_instance" "web" {
  ami           = "ami-079db87dc4c10ac91"
  instance_type = "t2.micro"
  
  tags = {
    Name = "web-server"
  }
  
  lifecycle {
    ignore_changes = [
      tags,           # Ignore tag changes
      instance_type,  # Ignore instance type changes
    ]
  }
}

# Ignore all attributes
lifecycle {
  ignore_changes = all
}
```

### 3. create_before_destroy
**Purpose:** Create replacement before destroying old resource

```hcl
resource "aws_instance" "web" {
  ami           = "ami-079db87dc4c10ac91"
  instance_type = "t2.micro"
  
  lifecycle {
    create_before_destroy = true  # Zero downtime
  }
}
```

### 4. depends_on
**Purpose:** Explicit dependency order

```hcl
resource "aws_instance" "web" {
  ami           = "ami-079db87dc4c10ac91"
  instance_type = "t2.micro"
  
  # Wait for VPC and security group
  depends_on = [
    aws_vpc.main,
    aws_security_group.web
  ]
}
```

---

## 13. PROVIDERS & ALIASES

### Multiple Regions with Aliases
```hcl
# Default provider (no alias)
provider "aws" {
  region = "us-east-1"
}

# Additional providers with aliases
provider "aws" {
  region = "us-west-2"
  alias  = "oregon"
}

provider "aws" {
  region = "ap-south-1"
  alias  = "mumbai"
}

provider "aws" {
  region = "eu-west-1"
  alias  = "ireland"
}
```

### Using Aliased Providers
```hcl
# Uses default provider (us-east-1)
resource "aws_instance" "virginia" {
  ami           = "ami-079db87dc4c10ac91"
  instance_type = "t2.micro"
}

# Uses oregon provider
resource "aws_instance" "oregon" {
  provider      = aws.oregon
  ami           = "ami-0abcdef1234567890"
  instance_type = "t2.micro"
}

# Uses mumbai provider
resource "aws_instance" "mumbai" {
  provider      = aws.mumbai
  ami           = "ami-08fe36427228eddc4"
  instance_type = "t2.micro"
}
```

### Other Providers

**Local File Provider**
```hcl
provider "local" {}

resource "local_file" "config" {
  filename = "/tmp/config.txt"
  content  = "Configuration content"
}
```

**GitHub Provider**
```hcl
provider "github" {
  token = "ghp_your_token_here"
  owner = "your-username"
}

resource "github_repository" "repo" {
  name        = "my-repo"
  description = "My repository"
  visibility  = "public"
}
```

---

## 14. IMPORT

### Purpose
Import manually created resources into Terraform management

### Import Process

**Step 1:** Create empty resource block
```hcl
resource "aws_instance" "imported" {
  # Empty - will be filled after import
}
```

**Step 2:** Import resource
```bash
terraform import aws_instance.imported i-0250ddb6b1487b017
```

**Step 3:** Get configuration
```bash
terraform state show aws_instance.imported
```

**Step 4:** Copy output to main.tf
```hcl
resource "aws_instance" "imported" {
  ami           = "ami-079db87dc4c10ac91"
  instance_type = "t2.micro"
  # ... other attributes from state show
}
```

**Step 5:** Verify
```bash
terraform plan  # Should show no changes
```

### Common Import Examples
```bash
# EC2 Instance
terraform import aws_instance.web i-1234567890abcdef0

# S3 Bucket
terraform import aws_s3_bucket.data my-bucket-name

# VPC
terraform import aws_vpc.main vpc-0123456789abcdef0

# Security Group
terraform import aws_security_group.web sg-0123456789abcdef0
```

---

## 15. VERSION CONSTRAINTS

### Purpose
Pin provider versions for stability

### Version Constraint Syntax
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.10.0"        # Exact version
    }
  }
}
```

### Version Operators

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.10.0"      # Greater than or equal
    }
    
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2"          # Any 2.2.x version
    }
    
    github = {
      source  = "integrations/github"
      version = ">= 5.0, < 6.0"   # Range
    }
  }
}
```

**Operators:**
- `= 5.10.0` - Exact version
- `>= 5.10.0` - Greater than or equal
- `~> 5.10.0` - Pessimistic constraint (5.10.x only)
- `>= 5.0, < 6.0` - Range

### Upgrade Providers
```bash
terraform init -upgrade
```

---

## 16. DYNAMIC BLOCKS & FOR_EACH

### Dynamic Blocks
**Purpose:** Generate repeated nested blocks in a loop

**Without Dynamic Block (Repetitive):**
```hcl
resource "aws_security_group" "web" {
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

**With Dynamic Block (Clean):**
```hcl
locals {
  ports = [443, 80, 22, 8080]
}

resource "aws_security_group" "web" {
  name = "web-sg"
  
  dynamic "ingress" {
    for_each = local.ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

**Complex Dynamic Block:**
```hcl
locals {
  ingress_rules = [
    { port = 443, description = "HTTPS" },
    { port = 80,  description = "HTTP" },
    { port = 22,  description = "SSH" },
    { port = 3306, description = "MySQL" },
  ]
}

resource "aws_security_group" "app" {
  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```

### for_each with Resources
**Purpose:** Create multiple resources from map/set

**With Map:**
```hcl
variable "instances" {
  type = map(string)
  default = {
    "web"  = "t2.micro"
    "app"  = "t2.small"
    "db"   = "t2.medium"
  }
}

resource "aws_instance" "servers" {
  for_each      = var.instances
  ami           = "ami-079db87dc4c10ac91"
  instance_type = each.value
  
  tags = {
    Name = each.key  # web, app, db
    Type = each.value # t2.micro, t2.small, t2.medium
  }
}
```

**Reference specific resource:**
```hcl
output "web_ip" {
  value = aws_instance.servers["web"].public_ip
}
```

**With Set:**
```hcl
variable "users" {
  type    = set(string)
  default = ["alice", "bob", "charlie"]
}

resource "aws_iam_user" "users" {
  for_each = var.users
  name     = each.key  # alice, bob, charlie
}
```

### count vs for_each

| Feature | count | for_each |
|---------|-------|----------|
| Input | Number/List | Map/Set |
| Index | Numeric (0,1,2) | Key-based |
| Deletion | Reindexes | Preserves keys |
| Reference | `resource[0]` | `resource["key"]` |
| Best for | Simple iteration | Named resources |

**Count with List:**
```hcl
variable "names" {
  default = ["web", "app", "db"]
}

resource "aws_instance" "servers" {
  count         = length(var.names)
  ami           = "ami-079db87dc4c10ac91"
  instance_type = "t2.micro"
  
  tags = {
    Name = var.names[count.index]
  }
}
```

---

## 17. STATE COMMANDS REFERENCE

### Complete State Command List

```bash
# List all resources
terraform state list

# Show resource details
terraform state show aws_instance.web

# Rename resource (no recreation)
terraform state mv aws_instance.old aws_instance.new

# Remove from tracking (resource stays in AWS)
terraform state rm aws_instance.legacy

# Pull remote state
terraform state pull > backup.tfstate

# Push state to backend (RISKY - avoid)
terraform state push terraform.tfstate

# Replace provider
terraform state replace-provider hashicorp/aws registry.terraform.io/hashicorp/aws
```

### State Command Use Cases

**Refactor Resource Name:**
```bash
terraform state mv aws_instance.old_name aws_instance.new_name
# Update main.tf to match new name
terraform plan  # Should show no changes
```

**Remove from Terraform Management:**
```bash
terraform state rm aws_instance.manual
# Resource still exists in AWS but Terraform won't manage it
```

**Backup State:**
```bash
terraform state pull > backup-$(date +%Y%m%d).tfstate
```

---

## 18. QUICK COMMAND REFERENCE

### Initialization & Planning
```bash
terraform init                      # Initialize directory
terraform init -upgrade             # Upgrade providers
terraform init -migrate-state       # Migrate to new backend
terraform validate                  # Validate syntax
terraform fmt                       # Format code
terraform plan                      # Preview changes
terraform plan -out=plan.tfplan     # Save plan
```

### Apply & Destroy
```bash
terraform apply                     # Apply with confirmation
terraform apply --auto-approve      # Apply without confirmation
terraform apply -var-file="dev.tfvar"  # Use variable file
terraform apply -target="aws_instance.web"  # Apply specific resource
terraform apply -replace="aws_instance.web"  # Force replace resource (NEW)
terraform destroy                   # Destroy with confirmation
terraform destroy --auto-approve    # Destroy without confirmation
terraform destroy -target="aws_instance.web"  # Destroy specific resource
```

### State Management
```bash
terraform state list                # List resources
terraform state show <resource>     # Show resource details
terraform state mv <src> <dst>      # Rename resource
terraform state rm <resource>       # Remove from state
terraform state pull                # Download state
terraform refresh                   # Sync state
```

### Workspace Operations
```bash
terraform workspace list            # List workspaces
terraform workspace new <name>      # Create workspace
terraform workspace select <name>   # Switch workspace
terraform workspace show            # Current workspace
terraform workspace delete <name>   # Delete workspace
```

### Import & Replace
```bash
terraform import <resource> <id>    # Import resource
terraform apply -replace="<resource>"  # Force replace (RECOMMENDED)
terraform taint <resource>          # Mark for recreation (DEPRECATED)
terraform untaint <resource>        # Unmark taint (DEPRECATED)
```

### Output & Console
```bash
terraform output                    # Show all outputs
terraform output <name>             # Show specific output
terraform console                   # Interactive console
terraform graph                     # Generate dependency graph

note: focus on 7,10,11,16.
