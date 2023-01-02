# Variables for subnet module
variable "vpc_id" {
    description = "ID of the VPC"
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

# variable "default_route_table_id" {
#     description = "ID of the default route table" 
# }