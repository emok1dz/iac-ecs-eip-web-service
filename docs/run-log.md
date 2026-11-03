# 运行记录

> 真实执行后填写（不得包含 AK/SK、密码）。

## 本地静态检查（无需凭证）
```
$ terraform fmt -recursive -check      # 无输出 = 格式正确
$ terraform validate
Success! The configuration is valid.
```
（Terraform v1.9.8，huaweicloud provider v1.100.0）

## 1. 参数修改（terraform.tfvars，未提交）
- allowed_source_ip：已改为本机公网 IP（此处不记录具体 IP）
- ecs_flavor_id：
- nginx_page_title / nginx_page_content：

## 2. terraform plan 摘要
## 3. 代码归档（apply 之前）
- commit：
- 仓库：https://github.com/emok1dz/iac-ecs-eip-web-service
## 4. terraform apply 结果与 outputs
## 5. curl 验证
## 6. terraform destroy（判题通过后）
