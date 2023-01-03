# Using EKS module to create an EKS cluster
module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "19.4.2"

    cluster_name = "eks-cluster"
    cluster_version = "1.24"

    # Networking configuration
    vpc_id = module.eks-vpc.vpc_id
    subnet_ids = module.eks-vpc.private_subnets # Subnets for worker nodes
    cluster_endpoint_public_access = true

    # Worker node configuration with node groups
    eks_managed_node_groups = {
        dev = {
            name = "dev-node-group"

            instance_types = ["t3.small"]

            min_size     = 1
            max_size     = 3
            desired_size = 1
        }
    }

    eks_managed_node_group_defaults = {
        ami_type = "AL2_x86_64"

    }


    tags = {
        environmnent = "dev"
        application = "my-app"
    }
}