# Terraform conf / manifests file in HashiCorp Configuration Language (HCL)

terraform {

# terraform.exe  version
# https://learn.hashicorp.com/tutorials/terraform/versions?in=terraform/configuration-language

  required_version = "~> 1.2"

# terraform init  // first time using provider
# terraform init  -upgrade  // if version changed
# cat .terraform.lock.hcl

# https://registry.terraform.io/browse/providers

  required_providers {
    myaws = {
      # source  = "registry.terraform.io/hashicorp/aws"
      # source = <HOSTNAME>/<NAMESPACE>/<TYPE>
      source  = "hashicorp/aws"
      version = "~> 4.15"
          }
    } 

}


# terraform init

# Configure the AWS Provider
# aws configure list-profiles

provider "myaws" {
    region = "ap-south-1"
    profile  = "default"

# static credentials
# access_key = "fe6365brgrg"
# secret_key = "ddgt5yy6u7i7ut3t45yg"

    
}

# Resource Block "Resource Type" "Resource Local Name"
resource "aws_instance" "os1" {

  # Argument Key = Value
  ami           = "ami-079b5e5b3971bd10d"
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    "sg-000e419b273321ff1"
  ]

  user_data = <<EOF
		#! /bin/bash
		yum install httpd -y
		echo "<h1>Deployed via Terraform</h1>" > /var/www/html/index.html
		systemctl enable httpd --now
		EOF

  tags = {
    Name = "TestOS1"
  }
}

# Attribute Reference
output "ec2_instance_publicip" {
	description = "EC2 public ip"
	value = aws_instance.os1.public_ip
}


/* terraform workflow
terraform validate
terraform plan
terraform apply
terraform destroy
*/
