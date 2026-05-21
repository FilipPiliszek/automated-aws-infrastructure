output "public_ip" {
  description = "public ip of the web server"
  value       = aws_instance.web_server.public_ip
}
