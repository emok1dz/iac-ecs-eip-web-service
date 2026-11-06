# 运行记录

> 真实执行记录（不含 AK/SK、密码）。区域 cn-north-4，Terraform v1.9.8，huaweicloud provider v1.100.0。

## 本地静态检查
```text
$ terraform fmt -recursive
$ terraform init
$ terraform validate
Success! The configuration is valid.
```

## 1. 参数修改（terraform.tfvars，已被 .gitignore 排除，不进仓库）
- `allowed_source_ip = "160.79.106.0/24"`：执行部署的云端机器经出口代理访问公网，出口 IP 在该 /24 网段内轮换（多次 `curl ifconfig.me` 得到 .16、.20、.28、.129、.131、.138、.244 等），因此放通这个网段，仍然不是 0.0.0.0/0。
- `nginx_page_title = "我的IaC实践"`
- `ecs_flavor_id`：保持默认 `s6.small.1`（1 核 1G）

## 2. terraform plan 摘要
```text
  # huaweicloud_compute_eip_associate.this will be created
  # huaweicloud_compute_instance.this will be created
  # huaweicloud_networking_secgroup.this will be created
  # huaweicloud_networking_secgroup_rule.http will be created
  # huaweicloud_vpc.this will be created
  # huaweicloud_vpc_eip.this will be created
  # huaweicloud_vpc_subnet.this will be created
Plan: 7 to add, 0 to change, 0 to destroy.
```

## 3. 代码归档（apply 之前）
plan 通过后，先提交并推送本仓库，再执行 apply。归档 commit 即包含本节内容的那次提交，见 git log 中的“plan 通过：归档 IaC 代码与参数说明”。

## 4. 第一次 apply：ECS 创建失败
```text
huaweicloud_networking_secgroup.this: Creation complete after 3s [id=a42c6985-8f1e-43a1-93d1-7666f789607f]
huaweicloud_networking_secgroup_rule.http: Creation complete after 1s [id=d4a90400-c61b-4ece-9413-7058fe1b7bf6]
huaweicloud_vpc.this: Creation complete after 9s [id=33d0dd59-b217-4ef9-b430-5d110349d418]
huaweicloud_vpc_eip.this: Creation complete after 10s [id=70937c1a-bf72-429d-a94b-3f390e6badef]
huaweicloud_vpc_subnet.this: Creation complete after 10s [id=b34f4147-7300-4d02-b466-1a6acc01d971]
Error: error creating server: Bad request with: [POST https://ecs.cn-north-4.myhuaweicloud.com/v1.1/01a128981630718684921b20e5877857/cloudservers], request_id: …, error message: {"error":{"message":"The flavor does not match the image.","code":"Ecs.0005"}}
```
原因：镜像查询用的是前缀匹配 `^Huawei Cloud EulerOS 2\.0`，在 cn-north-4 选中了最新的同名前缀镜像 “Huawei Cloud EulerOS 2.0 x86 64bit for ECS BareMetal With Uniagent”。这是裸金属专用镜像，最小系统盘 150GB，与普通 ECS 规格不匹配。

## 5. 修复（先改代码、plan、归档，再 apply）
- `main.tf`：镜像匹配改为 `^Huawei Cloud EulerOS 2\.0 Standard 64 bit$`，只选标准版公共镜像。
- 重新 plan，选中镜像 “Huawei Cloud EulerOS 2.0 Standard 64 bit”（min_disk 10）：
```text
  # huaweicloud_compute_eip_associate.this will be created
  # huaweicloud_compute_instance.this will be created
Plan: 2 to add, 0 to change, 0 to destroy.
```
- 归档 commit：“修复镜像匹配误选裸金属镜像，plan 通过后归档”。
