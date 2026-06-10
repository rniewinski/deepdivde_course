output "public_ip" {
  description = "Server public IP"
  value       = aws_eip.app.public_ip
}

output "app_url" {
  description = "Application URL"
  value       = "http://${aws_eip.app.public_ip}"
}

output "ssh_command" {
  description = "SSH into the server"
  value       = "ssh ec2-user@${aws_eip.app.public_ip}"
}
