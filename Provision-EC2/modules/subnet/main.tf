# Subnets and its networking resources
resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = var.vpc_id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.az

    tags = {
        Name = "${var.environment}-subnet-1"
    }
}

# Internet gateway to connect the VPC to the internet
resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = var.vpc_id

    tags = {
        Name = "${var.environment}-myapp-vpc-igw"
    }
}

# Route table to route traffic to IGW
resource "aws_route_table" "myapp-route-table" {
    vpc_id = var.vpc_id

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
#     default_route_table_id = var.default_route_table_id

#     route {
#         cidr_block = "0.0.0.0/0"
#         gateway_id = aws_internet_gateway.myapp-igw.id
#     }

#     tags = {
#         Name: "${var.environment}-myapp-vpc-default-route-table"
#     }
# }