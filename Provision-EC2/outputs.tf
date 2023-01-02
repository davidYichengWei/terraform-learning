# Output the public IP address of the EC2 instance
output "public_ip" {
    value = module.myapp-server.public_ip
}