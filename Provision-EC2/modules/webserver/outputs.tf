# Output the IP of the EC2 instance
output "public_ip" {
    value = aws_instance.myapp-server.public_ip
}