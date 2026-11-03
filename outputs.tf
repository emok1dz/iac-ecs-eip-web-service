output "vpc_id" {
  value = huaweicloud_vpc.this.id
}

output "subnet_id" {
  value = huaweicloud_vpc_subnet.this.id
}

output "security_group_id" {
  value = huaweicloud_networking_secgroup.this.id
}

output "ecs_instance_id" {
  value = huaweicloud_compute_instance.this.id
}

output "ecs_private_ip" {
  value = huaweicloud_compute_instance.this.access_ip_v4
}

output "ecs_public_ip" {
  description = "EIP 地址"
  value       = huaweicloud_vpc_eip.this.address
}

output "web_url" {
  description = "Web 服务地址（ECS 启动并安装 Nginx 约需 1~2 分钟）"
  value       = "http://${huaweicloud_vpc_eip.this.address}"
}
