terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Create ECR repositiories to hold our docker images
resource "aws_ecr_repository" "backend_repository" {
  name         = "backend-repository-k8s-3tier-app"
  force_delete = true
}

resource "aws_ecr_repository" "frontend_repository" {
  name         = "frontend-repository-k8s-3tier-app"
  force_delete = true
}

# Provision a new vpc for our EKS cluster
module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "5.0.0"
  name               = "eks-vpc-k8s-3tier-app"
  cidr               = "10.0.0.0/16"
  azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false
}

# Define the worker node group inside the eks module
# Add eks_managed_node_groups as part of the eks module block
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  eks_managed_node_group_defaults = {
    instance_types = ["t3.small"]
    iam_role_additional_policies = {
      AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }
  }

  eks_managed_node_groups = {
    main = {
      name         = var.node_group_name
      min_size     = 1
      max_size     = 3
      desired_size = 2

      capacity_type = "SPOT"
    }
  }
}

  
