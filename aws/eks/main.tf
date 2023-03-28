terraform {
    required_version = ">=1.3"
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "4.60.0"
        }
        kubectl = {
            source = "gavinbunney/kubectl"
            version = "1.14.0"
        }
    }
}

provider "aws" {
    region = local.region
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
}
data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

locals {
    cluster_name = "EKS01-Cluster"
    vpc_name = "EKS01-VPC"
    region = "ap-south-1"
    vpc_cidr = "10.0.0.0/16"
    azs = data.aws_availability_zones.available.names
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets =  ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

module vpc {
    source = "terraform-aws-modules/vpc/aws"
   
    name = local.vpc_name
    cidr = local.vpc_cidr
    
    azs = local.azs
    private_subnets = local.private_subnets
    public_subnets = local.public_subnets
    
    enable_nat_gateway = true
    single_nat_gateway = true
    enable_dns_hostnames= true

    tags = {
        "Name" = "EKS01-VPC"
    }
}

module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "19.10.0"
    vpc_id     = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets
    
    cluster_name = local.cluster_name
    # default cri is docker
    cluster_version = "1.23"
    eks_managed_node_groups = {
        primary = {
            name = "node-grp1"
            desired_size = 2
            min_size     = 1
            max_size     = 3
            labels = {
                role = "primary"
            }
        instance_types = ["t2.micro"]
        capacity_type  = "ON_DEMAND"
        }
        secondary = {
            name = "node-grp2"
            desired_size = 2
            min_size     = 1
            max_size     = 3
            labels = {
                role = "secondary"
            }
        instance_types = ["t2.micro"]
        capacity_type  = "ON_DEMAND"
        }
    }

    cluster_addons = {
        coredns = {
            most_recent = true
        }
        kube-proxy = {
            most_recent = true
        }
    }

    tags = {
        "Name" = "EKS01"
    }
}

output "cluster_endpoint" {
    description = "Endpoint of EKS"
    value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}
# connect to eks from aws cli (debugging purpose)
# aws eks --region $(terraform output -raw region) update-kubeconfig \
#    --name $(terraform output -raw cluster_name)
