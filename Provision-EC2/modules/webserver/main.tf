# Security group to allow ssh and http traffic
resource "aws_security_group" "myapp-sg" {
    name = "${var.environment}-myapp-sg"
    description = "sg for myapp-vpc to allow ssh and http traffic"
    vpc_id = var.vpc_id

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
        values = [var.image_name]
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
    subnet_id = var.subnet_id
    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    availability_zone = var.az
    associate_public_ip_address = true

    # Key pair to access the EC2 instance
    key_name = aws_key_pair.ssh-key.key_name

    tags = {
        Name = "${var.environment}-myapp-server"
    }

    # Commands to execute on the EC2 instance
        # Install docker and run nginx container
    user_data = file("ec2-entry-script.sh")
}
