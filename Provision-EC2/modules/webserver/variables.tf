# Variables for the webserver module
variable "vpc_id" {
    description = "ID of the VPC"
}

variable "az" {
    description = "Availability zone"
}

variable "environment" {
    description = "Type of the environment"
}

variable "my-ip" {
    description = "IP address allowed to connect to the EC2 instance"
}

variable "instance_type" {
    description = "Type of the EC2 instance"
}

variable "pub_key_location" {
    description = "Location of the public key"
    default = "~/.ssh/id_rsa.pub"
}

variable "image_name" {
    description = "Name of the image"
    default = "amzn2-ami-kernel-*-x86_64-gp2"
}

# Cannot access the subnet module from webserver module, need a variable
variable "subnet_id" {
    description = "ID of the subnet"
}