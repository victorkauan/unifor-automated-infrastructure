output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.nginx_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.nginx_server.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.nginx_server.public_dns
}

output "web_url" {
  description = "URL to access the web server"
  value       = "http://${aws_instance.nginx_server.public_ip}"
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${var.private_key_path} ubuntu@${aws_instance.nginx_server.public_ip}"
}
