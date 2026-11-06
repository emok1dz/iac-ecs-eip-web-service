# Web 服务：VPC → 子网 → 安全组（入站 80 仅放通指定 IP）→ EIP → ECS（user_data 安装 Nginx）→ 绑定 EIP

# 只匹配标准版公共镜像，避免选中同名前缀的裸金属专用镜像（如 "... for ECS BareMetal ..."）
data "huaweicloud_images_image" "this" {
  name_regex   = "^${replace(var.ecs_image_name, ".", "\\.")} Standard 64 bit$"
  visibility   = "public"
  architecture = "x86"
  most_recent  = true
}

resource "huaweicloud_vpc" "this" {
  name = var.vpc_name
  cidr = var.vpc_cidr
}

resource "huaweicloud_vpc_subnet" "this" {
  name              = var.subnet_name
  vpc_id            = huaweicloud_vpc.this.id
  cidr              = var.subnet_cidr
  gateway_ip        = var.subnet_gateway_ip
  availability_zone = var.availability_zone
}

# 默认规则保留出方向放通（ECS 需要访问软件源安装 Nginx）
resource "huaweicloud_networking_secgroup" "this" {
  name        = var.security_group_name
  description = "Managed by Terraform: allow HTTP from ${var.allowed_source_ip}"
}

resource "huaweicloud_networking_secgroup_rule" "http" {
  security_group_id = huaweicloud_networking_secgroup.this.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  ports             = "80"
  remote_ip_prefix  = var.allowed_source_ip
  description       = "HTTP from specified IP only"
}

resource "huaweicloud_vpc_eip" "this" {
  name = var.eip_name

  publicip {
    type = "5_bgp"
  }

  bandwidth {
    share_type  = "PER"
    name        = "${var.eip_name}-bw"
    size        = var.eip_bandwidth
    charge_mode = "traffic"
  }
}

resource "huaweicloud_compute_instance" "this" {
  name               = var.ecs_name
  availability_zone  = var.availability_zone
  flavor_id          = var.ecs_flavor_id
  image_id           = data.huaweicloud_images_image.this.id
  security_group_ids = [huaweicloud_networking_secgroup.this.id]
  system_disk_type   = var.ecs_disk_type
  system_disk_size   = var.ecs_disk_size
  admin_pass         = var.ecs_password != "" ? var.ecs_password : null

  # cloud-init 在首次启动时安装并启动 Nginx，写入自定义页面
  user_data = templatefile("${path.module}/templates/user_data.sh.tftpl", {
    title   = replace(replace(replace(var.nginx_page_title, "&", "&amp;"), "<", "&lt;"), ">", "&gt;")
    content = replace(replace(replace(var.nginx_page_content, "&", "&amp;"), "<", "&lt;"), ">", "&gt;")
  })

  network {
    uuid = huaweicloud_vpc_subnet.this.id
  }

  lifecycle {
    ignore_changes = [image_id]
  }
}

resource "huaweicloud_compute_eip_associate" "this" {
  public_ip   = huaweicloud_vpc_eip.this.address
  instance_id = huaweicloud_compute_instance.this.id
}
