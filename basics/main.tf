# Declare the AWS provider
provider "aws" {
    region = "us-east-1"
}


# Variables
variable "vpc_cidr_block" {
    description = "value for the vpc cidr block"
    default = "10.0.0.0/16"
    type = string
}

variable "dev-subnet-info" {
    description = "value for the subnet cidr block"
    type = list(object({
        cidr = string
        az = string
    }))
}

variable "environment" {
    description = "name of the environment"
    default = "dev"
    type = string
}


# Create a new VPC and subnet
resource "aws_vpc" "development-vpc" {
    cidr_block = var.vpc_cidr_block
    
    tags = {
        Name = "development-vpc"
        VPC_env = var.environment
    }
}

resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.development-vpc.id
    cidr_block = var.dev-subnet-info[0].cidr
    availability_zone = var.dev-subnet-info[0].az
}

resource "aws_subnet" "dev-subnet-2" {
    vpc_id = aws_vpc.development-vpc.id
    cidr_block = var.dev-subnet-info[1].cidr
    availability_zone = var.dev-subnet-info[1].az
}


# Add resources to default VPC
data "aws_vpc" "default_vpc" {
    default = true
}

resource "aws_subnet" "default_vpc_subnet" {
    vpc_id = data.aws_vpc.default_vpc.id
    cidr_block = "172.31.96.0/20"
    availability_zone = "us-east-1a"

    tags = {
        Name = "default_vpc_subnet"
    }
}


# Output values
output "dev-vpc-id" {
    value = aws_vpc.development-vpc.id
}

output "dev-subnet-id" {
    value = aws_subnet.dev-subnet-1.id
}