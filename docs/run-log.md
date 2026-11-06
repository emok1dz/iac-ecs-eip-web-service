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
