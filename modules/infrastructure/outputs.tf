output "nat-gateway-ip" {
  value = "${ aws_instance.nat.public_ip }"
}

output "test-ips" {
  value = "${ aws_instance.test.*.private_ip}"
}

output "prod-ips" {
  value = "${ aws_instance.prod.*.private_ip}"
}
