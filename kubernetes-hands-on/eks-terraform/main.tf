module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "simple-eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-2a", "us-east-2b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  # Required for EKS to function properly
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Start instances with public IPs since we have no NAT
  map_public_ip_on_launch = true

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name    = var.cluster_name
  kubernetes_version = "1.34"

  endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  # Minimal permissions for the node group
  enable_cluster_creator_admin_permissions = true

  addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    cheap_nodes = {
      min_size     = 2
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.small"]
      capacity_type  = "SPOT" # Even cheaper!
      ami_type       = "AL2023_x86_64_STANDARD"
      disk_size      = 20

      # Since we are in public subnets, nodes need public IPs to reach the EKS control plane endpoint
      # if we don't have VPC endpoints configured (which cost money).
      # However, Managed Node Groups usually handle this if configured correctly with public subnets.
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
