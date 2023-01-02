# Declare the AWS provider
provider "aws" {
    region = "us-east-1"
}

# Variables
variable "vpc_cidr_block" {
    description = "IP range for the VPC"
}

variable "subnet_cidr_block" {
    description = "IP range for the subnet"
}

variable "az" {
    description = "Availability zone"
}

variable "environment" {
    description = "Type of the environment"
}

variable "my-ip" {}


# VPC
resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block

    tags = {
        Name = "${var.environment}-vpc"
    }
}

# Subnets
resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.az

    tags = {
        Name = "${var.environment}-subnet-1"
    }
}

# Internet gateway to connect the VPC to the internet
resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id

    tags = {
        Name = "${var.environment}-myapp-vpc-igw"
    }
}

# Route table to route traffic to IGW
resource "aws_route_table" "myapp-route-table" {
    vpc_id = aws_vpc.myapp-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }

    tags = {
        Name: "${var.environment}-myapp-vpc-route-table"
    }
}

# Route table association with myapp-subnet-1
resource "aws_route_table_association" "myapp-route-table-association-1" {
    subnet_id = aws_subnet.myapp-subnet-1.id
    route_table_id = aws_route_table.myapp-route-table.id
}

# Alternative: edit the default route table to add the route to the IGW
# resource "aws_default_route_table" "myapp-default-route-table" {
#     default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

#     route {
#         cidr_block = "0.0.0.0/0"
#         gateway_id = aws_internet_gateway.myapp-igw.id
#     }

#     tags = {
#         Name: "${var.environment}-myapp-vpc-default-route-table"
#     }
# }

# Security group to allow ssh and http traffic
resource "aws_security_group" "myapp-sg" {
    name = "${var.environment}-myapp-sg"
    description = "sg for myapp-vpc to allow ssh and http traffic"
    vpc_id = aws_vpc.myapp-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my-ip]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow all outbound traffic
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name = "${var.environment}-myapp-sg"
    }
}

# Alternative: modify the default security group to allow ssh and http traffic
# resource "aws_default_security_group" "myapp-default-sg" {
#     vpc_id = aws_vpc.myapp-vpc.id

#     ingress {
#         from_port = 22
#         to_port = 22
#         protocol = "tcp"
#         cidr_blocks = [var.my-ip]
#     }

#     ingress {
#         from_port = 8080
#         to_port = 8080
#         protocol = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#     }

#     # Allow all outbound traffic
#     egress {
#         from_port = 0
#         to_port = 0
#         protocol = "-1"
#         cidr_blocks = ["0.0.0.0/0"]
#         prefix_list_ids = []
#     }

#     tags = {
#         Name = "${var.environment}-myapp-default-sg"
#     }
# }