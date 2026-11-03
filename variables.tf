# ---------------- 区域 ----------------
variable "region_name" {
  description = "区域"
  type        = string
  default     = "cn-north-4"
}

variable "availability_zone" {
  description = "可用区"
  type        = string
  default     = "cn-north-4a"
}

# ---------------- 网络 ----------------
variable "vpc_name" {
  type    = string
  default = "iac-eip-vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/16"
}

variable "subnet_name" {
  type    = string
  default = "iac-eip-subnet"
}

variable "subnet_cidr" {
  type    = string
  default = "192.168.0.0/24"
}

variable "subnet_gateway_ip" {
  type    = string
  default = "192.168.0.1"
}

variable "security_group_name" {
  type    = string
  default = "iac-eip-sg"
}

variable "allowed_source_ip" {
  description = "允许访问 80 端口的源 IP，格式 x.x.x.x/32（curl -s ifconfig.me）"
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_source_ip, 0)) && var.allowed_source_ip != "0.0.0.0/0"
    error_message = "allowed_source_ip 必须是合法 CIDR（如 1.2.3.4/32），且不能是 0.0.0.0/0。"
  }
}

# ---------------- ECS ----------------
variable "ecs_name" {
  type    = string
  default = "iac-eip-web"
}

variable "ecs_flavor_id" {
  description = "规格，默认 s6.small.1（1 核 1G），可改为 ac7.large.2（2 核 4G）等"
  type        = string
  default     = "s6.small.1"
}

variable "ecs_image_name" {
  description = "镜像名称（按前缀匹配最新公共镜像）"
  type        = string
  default     = "Huawei Cloud EulerOS 2.0"
}

variable "ecs_password" {
  description = "root 密码；留空则不设置密码（无法登录，但不影响 Web 服务）"
  type        = string
  default     = ""
  sensitive   = true
}

variable "ecs_disk_size" {
  type    = number
  default = 40
}

variable "ecs_disk_type" {
  type    = string
  default = "SSD"
}

# ---------------- EIP ----------------
variable "eip_name" {
  type    = string
  default = "iac-eip-web-eip"
}

variable "eip_bandwidth" {
  description = "带宽（Mbit/s），按流量计费"
  type        = number
  default     = 5
}

# ---------------- Nginx 页面 ----------------
variable "nginx_page_title" {
  type    = string
  default = "Hello from IaC"
}

variable "nginx_page_content" {
  type    = string
  default = "Nginx deployed by Terraform user_data"
}
