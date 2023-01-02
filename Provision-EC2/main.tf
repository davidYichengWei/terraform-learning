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

variable "instance_type" {
    description = "Type of the EC2 instance"
}

variable "pub_key_location" {
    description = "Location of the public key"
    default = "~/.ssh/id_rsa.pub"
}


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


### Create EC2 instance ###

# Query Amazon Linux 2 AMI using data source
data "aws_ami" "latest-amazon-linux-ami" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "name"
        values = ["amzn2-ami-kernel-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

# Key pair to access the EC2 instance
resource "aws_key_pair" "ssh-key" {
    key_name = "myapp-key"
    public_key = file(var.pub_key_location)
}

# EC2 instance
resource "aws_instance" "myapp-server" {
    # Required configurations
    ami = data.aws_ami.latest-amazon-linux-ami.id
    instance_type = var.instance_type

    # Network configurations
    subnet_id = aws_subnet.myapp-subnet-1.id
    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    availability_zone = var.az
    associate_public_ip_address = true

    # Key pair to access the EC2 instance
    key_name = aws_key_pair.ssh-key.key_name

    tags = {
        Name = "${var.environment}-myapp-server"
    }
}




# Output the public IP address of the EC2 instance
output "public_ip" {
    value = aws_instance.myapp-server.public_ip
}