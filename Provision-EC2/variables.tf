variable "vpc_cidr_block" {
    description = "IP range for the VPC"
}

variable "subnet_cidr_block" {
    description = "IP range for the subnet"
}

variable "az" {
    description = "Availability zone"
    default = "us-east-1a"
}

variable "environment" {
    description = "Type of the environment"
    default = "dev"
}

variable "my-ip" {
    description = "IP address allowed to connect to the EC2 instance"
}

variable "instance_type" {
    description = "Type of the EC2 instance"
    default = "t2.micro"
}

variable "pub_key_location" {
    description = "Location of the public key"
    default = "~/.ssh/id_rsa.pub"
}

variable "image_name" {
    description = "Name of the image"
    default = "amzn2-ami-kernel-*-x86_64-gp2"
}