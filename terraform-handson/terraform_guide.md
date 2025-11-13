# A Complete Guide to Terraform for a Single-Session Class

This guide serves as a comprehensive reference for our class on Terraform. It is designed to be a concise yet complete document you can follow along with and use for self-study afterward. We'll cover everything from the foundational principles to advanced, real-world concepts.

---

## Table of Contents
1. [Foundations: What is IaC & Why Terraform?](#foundations-what-is-iac--why-terraform)
2. [Installation and Setup](#installation-and-setup)
3. [Core Terraform Concepts](#core-terraform-concepts)
4. [The Standard Terraform Workflow](#the-standard-terraform-workflow)
5. [Hands-On Example: Your First Infrastructure](#hands-on-example-your-first-infrastructure)
6. [Managing Complexity with Modules](#managing-complexity-with-modules)
7. [Understanding Terraform State](#understanding-terraform-state)
8. [Best Practices](#best-practices)
9. [Advanced Concepts](#advanced-concepts)
10. [Troubleshooting Common Issues](#troubleshooting-common-issues)
11. [Next Steps and Resources](#next-steps-and-resources)

---

## Foundations: What is IaC & Why Terraform?

### What is Infrastructure as Code (IaC)?

Infrastructure as Code (IaC) is the practice of managing and provisioning infrastructure using machine-readable definition files, rather than manual processes or interactive tools.

**Traditional Infrastructure Management:**
- Manual configuration through web consoles
- Point-and-click operations
- Documentation becomes outdated
- Hard to reproduce environments
- Prone to human error

**IaC Approach:**
- Everything defined in code
- Version controlled
- Repeatable and consistent
- Self-documenting
- Automated deployment

### IaC Approaches

* **Imperative IaC:** You define the *steps* to reach a desired state (e.g., a shell script). "First, create a VM. Second, configure the firewall."
* **Declarative IaC:** You define the *desired end state*, and the tool figures out how to get there. "I want a VM with this configuration and this firewall rule."

**Terraform is a declarative IaC tool.**

### Why Terraform?

* **Platform Agnostic:** Manage infrastructure across multiple cloud providers (AWS, Azure, GCP) and other services (Kubernetes, Datadog) with a single tool.
* **State Management:** Terraform keeps a `state file`—a record of the infrastructure it manages. This allows Terraform to know what to create, update, or destroy.
* **Declarative Syntax:** You describe *what* you want, not *how* to create it, making configurations easier to read and maintain.
* **Planning & Safety:** The `terraform plan` command provides a "dry run" that shows you exactly what changes will be made before you apply them.
* **Large Ecosystem:** Thousands of providers and modules available.
* **Open Source:** Free to use with a strong community.

### Terraform vs Other Tools

| Tool | Type | Best For |
|------|------|----------|
| Terraform | Declarative | Multi-cloud infrastructure |
| AWS CloudFormation | Declarative | AWS-only environments |
| Ansible | Imperative/Config Mgmt | Configuration management |
| Pulumi | Declarative | Developers preferring general-purpose languages |

---

## Installation and Setup

### Installing Terraform

#### Option 1: Package Manager (Recommended)

**macOS (Homebrew):**
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

**Windows (Chocolatey):**
```powershell
choco install terraform
```

**Ubuntu/Debian:**
```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
```

#### Option 2: Manual Installation

1. Go to the official [Terraform download page](https://developer.hashicorp.com/terraform)
2. Download the package for your operating system and unzip it
3. Move the `terraform` executable to a directory in your system's `PATH`

### Verify Installation

```bash
terraform --version
```

You should see output like:
```
Terraform v1.5.0
on darwin_amd64
```

### Setting Up Cloud Provider Credentials

#### AWS Setup
```bash
# Install AWS CLI and configure
aws configure
# Or set environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

#### Azure Setup
```bash
# Install Azure CLI and login
az login
```

#### Google Cloud Setup
```bash
# Install gcloud CLI and authenticate
gcloud auth login
gcloud config set project your-project-id
```

---

## Core Terraform Concepts

Terraform code is written in HCL (HashiCorp Configuration Language), which is designed to be human-readable and declarative.

### File Structure

A typical Terraform project structure:
```
my-terraform-project/
├── main.tf          # Primary resources
├── variables.tf     # Input variable declarations
├── outputs.tf       # Output value declarations  
├── terraform.tfvars # Variable value assignments
├── versions.tf      # Provider version constraints
└── modules/         # Custom modules directory
    └── webserver/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### Providers

Providers are plugins that Terraform uses to interact with a specific API (e.g., AWS, Azure, GCP). They grant Terraform access to resources and data sources.

**Provider Declaration:**
```hcl
# versions.tf or main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      Environment = "Learning"
      ManagedBy   = "Terraform"
    }
  }
}
```

### Resources

A resource block defines a piece of infrastructure, like a virtual machine or a DNS record.

**Syntax:** `resource "TYPE" "NAME" { ... }`

- **TYPE** (`aws_instance`): The kind of resource to create
- **NAME** (`web_server`): A local name to refer to this resource in your code
- **ARGUMENTS** (`ami`, `instance_type`): The configuration for the resource

```hcl
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Machine Image ID
  instance_type = "t2.micro"
  key_name      = "my-key-pair"
  
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Terraform!</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "MyWebServer"
    Type = "WebServer"
  }
}
```

### Input Variables

Variables make your configuration flexible and reusable. You declare them using a `variable` block.

```hcl
# variables.tf
variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t2.micro"
  
  validation {
    condition     = contains(["t2.micro", "t2.small", "t2.medium"], var.instance_type)
    error_message = "Instance type must be t2.micro, t2.small, or t2.medium."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "server_ports" {
  description = "List of ports for the server"
  type        = list(number)
  default     = [80, 443]
}

variable "server_config" {
  description = "Server configuration"
  type = object({
    name     = string
    port     = number
    protocol = string
  })
  default = {
    name     = "web-server"
    port     = 80
    protocol = "HTTP"
  }
}
```

**Variable Types:**
- `string` - Text values
- `number` - Numeric values  
- `bool` - True/false values
- `list(type)` - Ordered collection
- `set(type)` - Unordered unique collection
- `map(type)` - Key-value pairs
- `object({...})` - Complex structured data

**Using Variables:**
```hcl
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = var.instance_type
  
  tags = {
    Name        = "${var.environment}-web-server"
    Environment = var.environment
  }
}
```

**Setting Variable Values:**

1. **terraform.tfvars file:**
```hcl
# terraform.tfvars
instance_type = "t2.small"
environment   = "production"
server_ports  = [80, 443, 8080]
```

2. **Command line:**
```bash
terraform apply -var="instance_type=t2.small" -var="environment=production"
```

3. **Environment variables:**
```bash
export TF_VAR_instance_type="t2.small"
export TF_VAR_environment="production"
```

### Outputs

Outputs are like return values. They expose information about the infrastructure you've created.

```hcl
# outputs.tf
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}

output "instance_url" {
  description = "URL to access the web server"
  value       = "http://${aws_instance.web_server.public_ip}"
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.web_sg.id
  sensitive   = false  # Set to true for sensitive data
}
```

### Data Sources

A `data` block fetches information about existing resources that are not managed by your current Terraform configuration.

```hcl
# Get the latest Ubuntu AMI
data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS account ID
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get current AWS region
data "aws_region" "current" {}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Use the data sources
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = var.instance_type
  
  tags = {
    Name      = "Server in ${data.aws_region.current.name}"
    AccountID = data.aws_caller_identity.current.account_id
  }
}
```

### Local Values

Local values assign a name to an expression for reuse within a module.

```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = "terraform-learning"
    ManagedBy   = "Terraform"
    CreatedBy   = data.aws_caller_identity.current.user_id
  }
  
  instance_name = "${var.environment}-${var.project_name}-web"
}

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = var.instance_type
  
  tags = merge(local.common_tags, {
    Name = local.instance_name
  })
}
```

---

## The Standard Terraform Workflow

This is the core loop you'll use every day with Terraform.

### 1. `terraform init`

**What it does:** Initializes the working directory by downloading provider plugins and setting up the backend.

**When to run:** 
- The first time you create a new configuration
- When you add a new provider
- When you change the backend configuration

```bash
terraform init
```

**Output example:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.17.0...
- Installed hashicorp/aws v5.17.0

Terraform has been successfully initialized!
```

### 2. `terraform validate`

**What it does:** Validates the configuration files for syntax errors and internal consistency.

```bash
terraform validate
```

### 3. `terraform fmt`

**What it does:** Formats your Terraform files to a canonical format and style.

```bash
terraform fmt
```

### 4. `terraform plan`

**What it does:** Creates a "dry run" execution plan. It compares your configuration to the state file and real-world infrastructure to show what will be changed.

```bash
terraform plan
# or save the plan to a file
terraform plan -out=tfplan
```

**Plan Symbols:**
- `+` Create new resource
- `-` Destroy existing resource  
- `~` Update resource in-place
- `-/+` Replace resource (destroy then create)
- `<=` Read data source

**Example output:**
```
Terraform will perform the following actions:

  # aws_instance.web_server will be created
  + resource "aws_instance" "web_server" {
      + ami                          = "ami-0c55b159cbfafe1f0"
      + instance_type               = "t2.micro"
      + public_ip                   = (known after apply)
      # ... more attributes
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

### 5. `terraform apply`

**What it does:** Executes the plan. It will show you the plan again and ask for confirmation before making changes.

```bash
terraform apply
# or apply a saved plan
terraform apply tfplan
# or auto-approve (use with caution!)
terraform apply -auto-approve
```

### 6. `terraform show`

**What it does:** Shows the current state or a saved plan.

```bash
terraform show
# or show a saved plan
terraform show tfplan
```

### 7. `terraform destroy`

**What it does:** Creates a plan to destroy all infrastructure managed by the configuration.

```bash
terraform destroy
# or destroy specific resources
terraform destroy -target=aws_instance.web_server
```

### Additional Useful Commands

```bash
# List all resources in state
terraform state list

# Show details of a specific resource
terraform state show aws_instance.web_server

# Import existing infrastructure
terraform import aws_instance.web_server i-1234567890abcdef0

# Refresh state to match real-world resources
terraform refresh

# Get provider documentation
terraform providers

# Validate and show configuration
terraform console
```

---

## Hands-On Example: Your First Infrastructure

Let's create a complete, working example that deploys a web server on AWS.

### Step 1: Create the Project Structure

```bash
mkdir terraform-webserver
cd terraform-webserver
```

### Step 2: Create the Configuration Files

**versions.tf:**
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

**main.tf:**
```hcl
provider "aws" {
  region = var.aws_region
}

# Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Create subnet
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.project_name}-subnet"
  }
}

# Create route table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name = "${var.project_name}-rt"
  }
}

# Associate route table with subnet
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# Create Security Group
resource "aws_security_group" "web" {
  name_prefix = "${var.project_name}-web-"
  vpc_id      = aws_vpc.main.id
  
  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this in production!
  }
  
  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

# Create EC2 instance
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.web.id]
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    server_name = var.project_name
  }))
  
  tags = {
    Name = "${var.project_name}-web-server"
  }
}
```

**variables.tf:**
```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-demo"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
```

**outputs.tf:**
```hcl
output "public_ip" {
  description = "Public IP address of the web server"
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "Public DNS name of the web server"
  value       = aws_instance.web.public_dns
}

output "website_url" {
  description = "URL of the website"
  value       = "http://${aws_instance.web.public_ip}"
}
```

**user_data.sh:**
```bash
#!/bin/bash
apt-get update
apt-get install -y nginx

# Create a custom index page
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to ${server_name}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; }
        h1 { color: #333; }
        .info { background: #f0f0f0; padding: 20px; margin: 20px 0; }
    </style>
</head>
<body>
    <h1>Hello from Terraform!</h1>
    <div class="info">
        <h2>Server Information</h2>
        <p><strong>Server Name:</strong> ${server_name}</p>
        <p><strong>Deployed with:</strong> Terraform</p>
        <p><strong>Instance ID:</strong> $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
        <p><strong>Availability Zone:</strong> $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>
    </div>
</body>
</html>
EOF

systemctl start nginx
systemctl enable nginx
```

**terraform.tfvars:**
```hcl
project_name  = "my-first-terraform"
instance_type = "t2.micro"
aws_region    = "us-east-1"
```

### Step 3: Deploy the Infrastructure

```bash
# Initialize Terraform
terraform init

# Validate the configuration
terraform validate

# Format the code
terraform fmt

# Preview changes
terraform plan

# Apply changes
terraform apply
```

### Step 4: Test Your Web Server

After deployment, Terraform will output the public IP. Visit `http://[PUBLIC_IP]` in your browser to see your web server!

### Step 5: Clean Up

```bash
terraform destroy
```

---

## Managing Complexity with Modules

A module is a self-contained package of Terraform configurations that are managed as a group. Think of them as "functions" for your infrastructure.

### Why Use Modules?

- **Reusability:** Write once, use many times
- **Organization:** Keep related resources together  
- **Maintainability:** Easier to update and debug
- **Collaboration:** Team members can work on different modules
- **Testing:** Modules can be tested independently

### Module Structure

```
modules/
└── webserver/
    ├── main.tf       # Resources
    ├── variables.tf  # Input variables
    ├── outputs.tf    # Output values
    └── README.md     # Documentation
```

### Creating a Module

**modules/webserver/variables.tf:**
```hcl
variable "name" {
  description = "Name for the webserver"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where instance will be launched"
  type        = string
}
```

**modules/webserver/main.tf:**
```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_security_group" "web" {
  name_prefix = "${var.name}-"
  vpc_id      = var.vpc_id
  
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
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.name}-sg"
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.web.id]
  
  user_data = base64encode(file("${path.module}/user_data.sh"))
  
  tags = {
    Name = var.name
  }
}
```

**modules/webserver/outputs.tf:**
```hcl
output "public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "instance_id" {
  description = "Instance ID"
  value       = aws_instance.web.id
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.web.id
}
```

### Using a Module

```hcl
# Call the webserver module
module "production_web_server" {
  source = "./modules/webserver"
  
  name          = "prod-web"
  instance_type = "t2.small"
  vpc_id        = aws_vpc.main.id
  subnet_id     = aws_subnet.main.id
}

module "staging_web_server" {
  source = "./modules/webserver"
  
  name          = "staging-web"
  instance_type = "t2.micro"
  vpc_id        = aws_vpc.main.id
  subnet_id     = aws_subnet.main.id
}

# Use outputs from modules
output "prod_server_ip" {
  value = module.production_web_server.public_ip
}

output "staging_server_ip" {
  value = module.staging_web_server.public_ip
}
```

### Module Sources

Modules can be sourced from various locations:

```hcl
# Local path
module "webserver" {
  source = "./modules/webserver"
}

# Terraform Registry
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
}

# Git repository
module "webserver" {
  source = "git::https://github.com/user/terraform-webserver-module.git"
}

# Git with specific branch/tag
module "webserver" {
  source = "git::https://github.com/user/terraform-webserver-module.git?ref=v1.0.0"
}
```

---

## Understanding Terraform State

### What is Terraform State?

The `terraform.tfstate` file is a JSON file that stores the state of your managed infrastructure. It serves as:

- **Mapping:** Links your configuration to real-world resources
- **Metadata Storage:** Tracks resource dependencies and attributes
- **Performance:** Caches resource attributes for large infrastructures
- **Locking:** Prevents concurrent operations (with remote backends)

### State File Contents

```json
{
  "version": 4,
  "terraform_version": "1.5.0",
  "serial": 1,
  "lineage": "abc123",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "aws_instance",
      "name": "web",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 1,
          "attributes": {
            "id": "i-1234567890abcdef0",
            "ami": "ami-0c55b159cbfafe1f0",
            "instance_type": "t2.micro",
            "public_ip": "203.0.113.12"
          }
        }
      ]
    }
  ]
}
```

### Local vs Remote State

#### Local State (Default)
- Stored in `terraform.tfstate` in your project directory
- Good for learning and solo projects
- **Problems with teams:**
  - No collaboration - conflicts when multiple people work
  - No locking - concurrent runs can corrupt state
  - Security - sensitive data in plain text locally

#### Remote State (Production)
- Stored in a shared backend (S3, Azure Blob, GCS, etc.)
- Enables team collaboration
- Provides state locking
- Better security with encryption

### Configuring Remote State with S3

**Step 1: Create S3 bucket and DynamoDB table**
```hcl
# bootstrap/main.tf - Run this first to create backend resources
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state-bucket-unique-name-123"
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  name           = "terraform-state-locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  tags = {
    Name = "Terraform State Locks"
  }
}
```

**Step 2: Configure backend in your main project**
```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-unique-name-123"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
}
```

**Step 3: Initialize with new backend**
```bash
terraform init
```

### State Commands

```bash
# List all resources in state
terraform state list

# Show details of specific resource
terraform state show aws_instance.web

# Move resource to different address
terraform state mv aws_instance.old_name aws_instance.new_name

# Remove resource from state (but keep the real resource)
terraform state rm aws_instance.web

# Import existing resource into state
terraform import aws_instance.web i-1234567890abcdef0

# Pull remote state to local copy
terraform state pull

# Push local state to remote backend
terraform state push terraform.tfstate
```

### State Best Practices

1. **Never edit state files manually** - Use Terraform commands only
2. **Always use remote state for teams** - Local state doesn't scale
3. **Enable state locking** - Prevents corruption from concurrent operations
4. **Backup state regularly** - State is critical and can't be easily recreated
5. **Use separate state files per environment** - Isolate prod/staging/dev
6. **Be careful with sensitive data** - State files contain all resource attributes

---

## Best Practices

### Project Organization

#### Directory Structure for Multiple Environments
```
terraform-infrastructure/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   └── prod/
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       └── backend.tf
├── modules/
│   ├── vpc/
│   ├── webserver/
│   └── database/
└── global/
    ├── iam/
    └── route53/
```

#### Alternative: Workspace-based Structure
```
terraform-infrastructure/
├── main.tf
├── variables.tf
├── outputs.tf
├── backend.tf
├── dev.tfvars
├── staging.tfvars
├── prod.tfvars
└── modules/
```

### Naming Conventions

**Resources:**
```hcl
# Use descriptive, consistent names
resource "aws_instance" "web_server" {}        # Good
resource "aws_instance" "i" {}                 # Bad

# Include environment in name
resource "aws_instance" "prod_web_server" {}   # Good
resource "aws_instance" "web_server_prod" {}   # Also good
```

**Variables:**
```hcl
# Use snake_case
variable "instance_type" {}     # Good
variable "instanceType" {}      # Bad

# Be descriptive
variable "instance_type" {}     # Good  
variable "type" {}              # Too vague
```

**Tags:**
```hcl
# Use consistent tagging strategy
tags = {
  Name        = "${var.environment}-web-server"
  Environment = var.environment
  Project     = var.project_name
  Owner       = var.owner
  ManagedBy   = "Terraform"
  CostCenter  = var.cost_center
}
```

### Code Organization

**Split configurations into logical files:**
```hcl
# versions.tf - Provider requirements
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# variables.tf - All input variables
variable "environment" {
  description = "Environment name"
  type        = string
}

# locals.tf - Local values and computed data
locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# data.tf - All data sources
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
}

# main.tf - Primary resources
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
}

# outputs.tf - All outputs
output "instance_ip" {
  value = aws_instance.web.public_ip
}
```

### Variable Management

**Use validation rules:**
```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
  
  validation {
    condition     = can(regex("^t[2-4]\\.", var.instance_type))
    error_message = "Instance type must be from t2, t3, or t4 family."
  }
}
```

**Provide good descriptions:**
```hcl
variable "vpc_cidr" {
  description = "CIDR block for VPC. Should be a valid IPv4 CIDR block."
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}
```

### Security Best Practices

**Never hardcode secrets:**
```hcl
# Bad - hardcoded password
resource "aws_db_instance" "main" {
  password = "supersecret123"  # Don't do this!
}

# Good - use random password
resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "aws_db_instance" "main" {
  password = random_password.db_password.result
}

# Better - use AWS Secrets Manager
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/db/password"
}

resource "aws_db_instance" "main" {
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
}
```

**Restrict security groups:**
```hcl
# Bad - too open
resource "aws_security_group" "web" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Anyone can SSH!
  }
}

# Good - restricted access
resource "aws_security_group" "web" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr_block]  # Only admins
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Public HTTP is OK
  }
}
```

### Version Control

**Use `.gitignore`:**
```gitignore
# .gitignore
*.tfstate
*.tfstate.*
*.tfvars
*.tfplan
.terraform/
.terraform.lock.hcl
crash.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json
```

**Pin provider versions:**
```hcl
# Good - specific version constraints
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.17.0"  # Allow patch updates
    }
  }
}

# Bad - no version constraint
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # No version specified!
    }
  }
}
```

### Documentation

**Document your code:**
```hcl
# Create VPC for the application
# This VPC will host all application resources including:
# - Web servers in public subnets
# - Database servers in private subnets  
# - NAT gateways for outbound internet access
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(local.common_tags, {
    Name = "${var.environment}-vpc"
  })
}
```

**Create README files:**
```markdown
# Web Application Infrastructure

This Terraform configuration creates a web application infrastructure on AWS.

## Architecture

- VPC with public and private subnets
- Auto Scaling Group for web servers
- RDS database in private subnet
- Application Load Balancer

## Usage

1. Configure AWS credentials
2. Copy `terraform.tfvars.example` to `terraform.tfvars`
3. Update variables in `terraform.tfvars`
4. Run `terraform init`
5. Run `terraform plan`
6. Run `terraform apply`

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| environment | Environment name | string | - |
| instance_type | EC2 instance type | string | t2.micro |

## Outputs

| Name | Description |
|------|-------------|
| load_balancer_dns | DNS name of the load balancer |
| database_endpoint | RDS database endpoint |
```

---

## Advanced Concepts

### Workspaces

Workspaces allow you to manage multiple distinct states for the same configuration. This is useful for managing different environments without duplicating code.

```bash
# List workspaces
terraform workspace list

# Create new workspace
terraform workspace new development
terraform workspace new staging
terraform workspace new production

# Switch between workspaces
terraform workspace select development

# Show current workspace
terraform workspace show

# Delete workspace (must be empty)
terraform workspace delete development
```

**Using workspace in configuration:**
```hcl
locals {
  environment = terraform.workspace
  
  # Different instance sizes per environment
  instance_type = {
    development = "t2.micro"
    staging     = "t2.small" 
    production  = "t2.medium"
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.instance_type[local.environment]
  
  tags = {
    Name        = "${local.environment}-web-server"
    Environment = local.environment
  }
}

# Different backend state files per workspace
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "env/${terraform.workspace}/terraform.tfstate"
    region = "us-east-1"
  }
}
```

### Provisioners

Provisioners execute scripts on a local or remote machine as part of resource creation. **Use sparingly!**

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = var.key_name
  
  # File provisioner - copy files to remote machine
  provisioner "file" {
    source      = "app.conf"
    destination = "/tmp/app.conf"
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
  
  # Remote-exec provisioner - run commands on remote machine
  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/app.conf /etc/app/app.conf",
      "sudo systemctl restart app"
    ]
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
  
  # Local-exec provisioner - run commands locally
  provisioner "local-exec" {
    command = "echo 'Instance ${self.id} created!'"
  }
  
  # Null resource with provisioner for complex scenarios
}

# Better approach: Use user_data or configuration management
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  
  user_data = base64encode(templatefile("userdata.sh", {
    app_config = var.app_config
  }))
}
```

**Why avoid provisioners?**
- Make Terraform stateful
- Hard to debug
- Not idempotent
- Better alternatives exist (cloud-init, AMI baking, configuration management)

### Lifecycle Rules

Control resource lifecycle behavior:

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  lifecycle {
    # Create new resource before destroying old one
    create_before_destroy = true
    
    # Prevent accidental deletion
    prevent_destroy = true
    
    # Ignore changes to specific attributes
    ignore_changes = [
      # Ignore AMI changes (might be patched externally)
      ami,
      # Ignore tags that might be added by other tools
      tags["LastPatched"]
    ]
    
    # Replace resource when specific attributes change
    replace_triggered_by = [
      aws_security_group.web.id
    ]
  }
  
  tags = {
    Name = "web-server"
  }
}

# Lifecycle with null_resource for complex scenarios
resource "null_resource" "cluster" {
  triggers = {
    cluster_instance_ids = join(",", aws_instance.cluster.*.id)
  }
  
  provisioner "local-exec" {
    command = "echo 'Cluster configuration changed!'"
  }
  
  lifecycle {
    replace_triggered_by = [aws_instance.cluster]
  }
}
```

### Dynamic Blocks

Generate repeated nested blocks dynamically:

```hcl
variable "security_group_rules" {
  description = "List of security group rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

resource "aws_security_group" "web" {
  name_prefix = "web-"
  vpc_id      = var.vpc_id
  
  # Dynamic ingress rules
  dynamic "ingress" {
    for_each = var.security_group_rules
    iterator = rule
    
    content {
      from_port   = rule.value.from_port
      to_port     = rule.value.to_port
      protocol    = rule.value.protocol
      cidr_blocks = rule.value.cidr_blocks
    }
  }
  
  # Static egress rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Dynamic subnets
variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  count = length(var.availability_zones)
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}
```

### Meta-Arguments

**`count`** - Create multiple instances of a resource:
```hcl
# Create multiple instances
resource "aws_instance" "web" {
  count = var.instance_count
  
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  
  tags = {
    Name = "web-server-${count.index + 1}"
  }
}

# Reference instances
output "instance_ips" {
  value = aws_instance.web[*].public_ip
}
```

**`for_each`** - Create resources based on a map or set:
```hcl
variable "users" {
  type = map(object({
    role = string
    department = string
  }))
  default = {
    john = {
      role = "developer"
      department = "engineering"
    }
    jane = {
      role = "manager"  
      department = "engineering"
    }
  }
}

resource "aws_iam_user" "users" {
  for_each = var.users
  
  name = each.key
  
  tags = {
    Role       = each.value.role
    Department = each.value.department
  }
}

# Reference specific user
output "john_arn" {
  value = aws_iam_user.users["john"].arn
}

# Reference all users
output "all_user_arns" {
  value = values(aws_iam_user.users)[*].arn
}
```

**`depends_on`** - Explicit dependencies:
```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  
  # Explicit dependency - wait for security group
  depends_on = [aws_security_group.web]
}

resource "aws_security_group" "web" {
  name_prefix = "web-"
  vpc_id      = aws_vpc.main.id
}
```

### Functions

Terraform includes many built-in functions:

```hcl
locals {
  # String functions
  environment = upper(var.environment)              # Convert to uppercase
  server_name = format("%s-web-server", var.env)   # String formatting
  
  # Collection functions
  all_subnets = concat(var.public_subnets, var.private_subnets)
  subnet_count = length(var.subnets)
  first_subnet = element(var.subnets, 0)
  
  # Numeric functions
  max_size = max(var.min_size, 3)
  
  # Date/time functions
  current_time = timestamp()
  
  # Encoding functions
  user_data = base64encode(file("userdata.sh"))
  
  # File functions
  config_file = file("${path.module}/config.yaml")
  
  # Type conversion
  instance_count = tonumber(var.instance_count_string)
  
  # Conditional logic
  instance_type = var.environment == "prod" ? "t2.large" : "t2.micro"
  
  # Complex expressions with for
  subnet_cidrs = [for i, subnet in var.subnets : cidrsubnet(var.vpc_cidr, 8, i)]
  
  # Map transformations
  tagged_users = {
    for name, user in var.users :
    name => merge(user, {
      created_by = "terraform"
      created_at = timestamp()
    })
  }
}
```

### Conditional Expressions

```hcl
# Ternary operator
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.environment == "production" ? "t2.large" : "t2.micro"
  
  # Conditional resource creation
  count = var.create_instance ? 1 : 0
  
  tags = {
    Name = var.environment == "production" ? "prod-web" : "dev-web"
    
    # Conditional tag
    Backup = var.environment == "production" ? "daily" : null
  }
}

# Conditional blocks
dynamic "ebs_block_device" {
  for_each = var.environment == "production" ? [1] : []
  
  content {
    device_name = "/dev/sdf"
    volume_size = 100
    volume_type = "gp3"
  }
}
```

---

## Troubleshooting Common Issues

### State Issues

**Problem:** "Resource already exists"
```
Error: resource already exists
```

**Solution:** Import existing resource
```bash
# Find the resource ID from AWS console
terraform import aws_instance.web i-1234567890abcdef0
```

**Problem:** State file corruption
```
Error: state snapshot was created by Terraform v1.4.0, which is newer than current v1.3.0
```

**Solution:** Upgrade Terraform or restore from backup
```bash
# Upgrade Terraform
terraform version
# Or restore state from backup
terraform state pull > backup.tfstate
```

**Problem:** State lock issues
```
Error: Error acquiring the state lock
```

**Solution:** Force unlock (use carefully!)
```bash
# Get lock ID from error message
terraform force-unlock LOCK_ID
```

### Configuration Issues

**Problem:** Circular dependency
```
Error: Cycle: aws_security_group.web, aws_instance.web
```

**Solution:** Break the cycle
```hcl
# Bad - circular reference
resource "aws_instance" "web" {
  vpc_security_group_ids = [aws_security_group.web.id]
}

resource "aws_security_group" "web" {
  ingress {
    security_groups = [aws_instance.web.security_groups[0]]
  }
}

# Good - use separate security group rule
resource "aws_instance" "web" {
  vpc_security_group_ids = [aws_security_group.web.id]
}

resource "aws_security_group" "web" {
  # Basic rules only
}

resource "aws_security_group_rule" "web_self" {
  type                     = "ingress"
  from_port               = 80
  to_port                 = 80
  protocol                = "tcp"
  security_group_id       = aws_security_group.web.id
  source_security_group_id = aws_security_group.web.id
}
```

**Problem:** Invalid resource reference
```
Error: Reference to undeclared resource
```

**Solution:** Check resource names and references
```hcl
# Make sure resource exists and name matches
resource "aws_vpc" "main" {  # Resource name is "main"
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id  # Reference matches resource name
}
```

### Provider Issues

**Problem:** Provider initialization fails
```
Error: Failed to install provider
```

**Solution:** Clear and reinitialize
```bash
rm -rf .terraform
terraform init
```

**Problem:** Provider version conflicts
```
Error: Incompatible provider version
```

**Solution:** Update version constraints
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0, < 6.0"  # More flexible range
    }
  }
}
```

### Plan/Apply Issues

**Problem:** Timeout during apply
```
Error: timeout while waiting for resource to reach target state
```

**Solution:** Increase timeout or check resource dependencies
```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  
  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}
```

**Problem:** Authentication errors
```
Error: AccessDenied
```

**Solution:** Check AWS credentials and permissions
```bash
# Verify AWS credentials
aws sts get-caller-identity

# Check environment variables
env | grep AWS

# Verify IAM permissions
aws iam get-user
aws iam list-attached-user-policies --user-name your-username
```

### Debugging Tips

**Enable detailed logging:**
```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log
terraform apply
```

**Use terraform console for testing:**
```bash
terraform console
> var.instance_type
> data.aws_ami.ubuntu.id
> local.common_tags
```

**Validate configuration frequently:**
```bash
terraform validate
terraform fmt -check
terraform plan -detailed-exitcode
```

---

## Next Steps and Resources

### Terraform Certification

HashiCorp offers official certification:
- **Terraform Associate (003)** - Entry level certification
- Study guide: [HashiCorp Learn](https://learn.hashicorp.com/terraform)
- Practice exams and hands-on labs

### Advanced Topics to Explore

1. **Terraform Cloud/Enterprise**
   - Remote execution
   - Policy as Code (Sentinel)
   - Private module registry
   - Cost estimation

2. **Testing Infrastructure**
   - Terratest (Go-based testing)
   - Kitchen-Terraform
   - Automated testing pipelines

3. **CI/CD Integration**
   - GitLab CI/CD
   - GitHub Actions
   - Jenkins
   - Azure DevOps

4. **Advanced Patterns**
   - Multi-account AWS deployments
   - Blue/green deployments
   - Canary releases
   - Infrastructure drift detection

5. **Security and Compliance**
   - Terraform security scanning (Checkov, tfsec)
   - Policy as Code
   - Secret management
   - Compliance frameworks

### Useful Tools

**Code Quality:**
- `terraform fmt` - Format code
- `terraform validate` - Validate syntax
- `tflint` - Linting tool
- `checkov` - Security scanning
- `tfsec` - Security analysis

**Documentation:**
- `terraform-docs` - Generate documentation
- `pre-commit` hooks for validation
- IDE plugins (VS Code, IntelliJ)

**State Management:**
- `terraform state` commands
- Terragrunt for DRY configurations
- Atlantis for PR-based workflows

### Learning Resources

**Official Documentation:**
- [Terraform Registry](https://registry.terraform.io/) - Providers and modules
- [HashiCorp Learn](https://learn.hashicorp.com/terraform) - Official tutorials
- [Terraform Documentation](https://terraform.io/docs) - Complete reference

**Books:**
- "Terraform: Up & Running" by Yevgeniy Brikman
- "Infrastructure as Code" by Kief Morris
- "Terraform in Action" by Scott Winkler

**Community:**
- [Terraform Community Forum](https://discuss.hashicorp.com/c/terraform-core)
- [r/Terraform](https://reddit.com/r/Terraform)
- [Terraform GitHub](https://github.com/hashicorp/terraform)

**Practice Labs:**
- AWS Free Tier for hands-on practice
- [Terraform Examples](https://github.com/terraform-providers/terraform-provider-aws/tree/main/examples)
- [Cloud Provider Quick Starts](https://learn.hashicorp.com/collections/terraform/cloud-get-started)

### Sample Projects to Build

1. **Beginner**: Single web server with security group
2. **Intermediate**: Multi-tier application (web, app, database layers)
3. **Advanced**: Auto-scaling web application with load balancer
4. **Expert**: Multi-region, multi-account deployment with CI/CD

### Final Tips

1. **Start small** - Don't try to terraform everything at once
2. **Use modules** - Build reusable components
3. **Plan before applying** - Always review changes
4. **Version everything** - Code, state, and provider versions
5. **Test thoroughly** - Validate in non-production first
6. **Monitor changes** - Track who changed what and when
7. **Keep learning** - Terraform and cloud services evolve rapidly

Remember: Infrastructure as Code is a journey, not a destination. Start with simple examples, build confidence, and gradually tackle more complex scenarios. The key is consistent practice and continuous learning.

---

*This guide provides a solid foundation for learning Terraform. Keep this document as a reference and don't hesitate to experiment with the examples. Happy terraforming!*