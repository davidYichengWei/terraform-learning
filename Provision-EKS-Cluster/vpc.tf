# A list of all AZs in the region
data "aws_availability_zones" "azs" {}

# Using VPC module to create a VPC for the EKS cluster
module "eks-vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "3.18.1"

    name = "eks-vpc"

    # Networking configuration
    cidr = var.vpc_cidr_block
    private_subnets = var.private_subnet_cidr_blocks
    public_subnets = var.public_subnet_cidr_blocks
    azs  = slice(data.aws_availability_zones.azs.names, 0, 3)

    # NAT gateway for private subnets
    enable_nat_gateway = true
    single_nat_gateway = true

    # Assign EC2 instances public and private DNS names
    enable_dns_hostnames = true

    # Tags for the control plane to reference the VPC and subnets
    tags = {
        "kubernetes.io/cluster/eks-vpc" = "shared"
    }
    public_subnet_tags = {
        "kubernetes.io/cluster/eks-vpc" = "shared"
        "kubernetes.io/role/elb" = 1 # For AWS to provision ELB open to the internet
    }
    private_subnet_tags = {
        "kubernetes.io/cluster/eks-vpc" = "shared"
        "kubernetes.io/role/internal-elb" = 1
    }
}