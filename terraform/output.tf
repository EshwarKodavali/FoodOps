# Display public IP
output "foodops_public_ip" {

  value = aws_instance.foodops.public_ip
}
