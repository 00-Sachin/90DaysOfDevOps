output "web_server_ip" {
  description = "Public IP of the Web Server"
  value       = module.web_server.public_ip
}

output "api_server_ip" {
  description = "Public IP of the API Server"
  value       = module.api_server.public_ip
}