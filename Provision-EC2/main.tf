# Declare the AWS provider
provider "aws" {
    region = "us-east-1"
}


# VPC
resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block

    tags = {
        Name = "${var.environment}-vpc"
    }
}

# Subnets and its networking resources
module "myapp-subnet" {
    source = "./modules/subnet"
    vpc_id = aws_vpc.myapp-vpc.id
    subnet_cidr_block = var.subnet_cidr_block
    az = var.az
    environment = var.environment
    # default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
}

# EC2 instance with sg and key pair running nginx
module "myapp-server" {
    source = "./modules/webserver"
    vpc_id = aws_vpc.myapp-vpc.id
    subnet_id = module.myapp-subnet.subnet_id
    environment = var.environment
    my-ip = var.my-ip
    instance_type = var.instance_type
    pub_key_location = var.pub_key_location
    image_name = var.image_name
    az = var.az
}