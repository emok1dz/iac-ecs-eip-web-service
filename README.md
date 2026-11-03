# IaC工程化部署Web服务

ICT 大赛实践赛题 **1.20「基于 IaC 工程化的 Web 服务部署与代码归档」** 作品。

本仓库就是 IaC 代码的**归档仓库**。标准流程是“修改参数 → plan 验证 → 提交归档 → apply 部署”，即**代码先于资源**：任何资源变更都能在 git 历史中追溯，出了问题可以用 `git revert` 回滚。

## 部署内容

| 资源 | 说明 |
| --- | --- |
| VPC + 子网 | `192.168.0.0/16` / `192.168.0.0/24` |
| 安全组 | 入站只允许**指定 IP** 访问 TCP **80** |
| EIP | 5_bgp，5 Mbit/s，按流量计费 |
| ECS | 默认 `s6.small.1`（1 核 1G），Huawei Cloud EulerOS 2.0，40GB SSD |
| Nginx | 通过 `user_data`（cloud-init）在首次启动时自动安装，并写入自定义页面，无需 SSH 登录 |
| EIP 绑定 | `huaweicloud_compute_eip_associate` |

## 文件

| 文件 | 作用 | 是否需要修改 |
| --- | --- | --- |
| `versions.tf` | Provider 配置（凭证走环境变量） | 否 |
| `variables.tf` | 变量定义（`allowed_source_ip` 带校验，禁止 `0.0.0.0/0`） | 否 |
| `main.tf` | 资源定义 | 否 |
| `templates/user_data.sh.tftpl` | Nginx 安装脚本模板 | 否 |
| `outputs.tf` | 输出 EIP、Web 地址等 | 否 |
| `terraform.tfvars.example` | 参数模板 | 复制为 `terraform.tfvars` 后**只改这个文件** |
| `.gitignore` | 排除 `terraform.tfvars`（实际参数）和 `*.tfstate`（资源状态） | 否 |
| `docs/run-log.md` | 运行记录 | 运行后填写 |

## 工程化流程

```bash
# 0. 凭证（PowerShell 用 $env:HW_ACCESS_KEY="..."）
export HW_ACCESS_KEY="你的AK"
export HW_SECRET_KEY="你的SK"

# 1. 修改参数：allowed_source_ip 必改，ecs_flavor_id / nginx_page_* 可选
cp terraform.tfvars.example terraform.tfvars

# 2. plan 验证
terraform fmt -recursive
terraform init
terraform validate
terraform plan

# 3. 提交归档（apply 之前！）
git add -A && git commit -m "feat: web service on ECS+EIP" && git push

# 4. 部署
terraform apply

# 5. 验证（ECS 启动并安装 Nginx 约需 1~2 分钟）
curl "$(terraform output -raw web_url)"
# 预期：<h1>Hello from IaC</h1><p>Nginx deployed by Terraform user_data</p>

# 6. 判题通过后清理
terraform destroy
```

费用：ECS s6.small.1 约 0.04 元/小时，40GB SSD 约 0.03 元/小时，EIP 5M 按流量计费约 0.02 元/小时，2 小时合计约 0.2 元。

## 安全设计

- 凭证只走环境变量；`terraform.tfvars`、`*.tfstate` 不进仓库；
- `ecs_password` 标记为 `sensitive`，留空时不设置密码；
- 安全组只放通单个源 IP 的 80 端口；出方向使用默认规则，供 ECS 访问软件源安装 Nginx。
