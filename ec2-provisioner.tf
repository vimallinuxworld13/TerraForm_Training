terraform {
 required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15"
          }
    } 
}

provider "aws" {
    region = "ap-south-1"
    profile  = "default"
}

resource "aws_instance" "myweb" {

  ami           = "ami-079b5e5b3971bd10d"
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    "sg-000e419b273321ff1"
  ]

  key_name	= "key_aws_training_2022"

provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd git -y",
      "sudo systemctl enable httpd --now",

    ]
  }

  connection {
    type   	 = "ssh"
    user    	 = "ec2-user"
    private_key  = file("C:/Users/Vimal Daga/Downloads/key_aws_training_2022.pem")
    host    	 = self.public_ip
  }

  tags = {
    Name = "LinuxWorld"
  }

}


resource "null_resource" "nulllocal1" {
provisioner "local-exec" {
    command = "echo ${aws_instance.myweb.public_ip} > public_ip.txt"
  }
}



resource "aws_ebs_volume" "ebs1" {
  availability_zone = aws_instance.myweb.availability_zone
  size              = 1

  tags = {
    Name = "HelloWorldebs"
  }
}


resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ebs1.id
  instance_id = aws_instance.myweb.id
  force_detach = true
}


resource "null_resource" "nullremote1" {
provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4 /dev/xvdh",
      "sudo mount /dev/xvdh /var/www/html",
      "sudo rm -rf /var/www/html/lost+found",
      "sudo git clone https://github.com/vimallinuxworld13/devopsal1.git /var/www/html/",
    ]
  }


provisioner "file" {
    source      = "C:/Users/Vimal Daga/Desktop/terraform_code/ec2/vimal.jpg"
    destination = "/var/www/html/vimal.jpg"
    on_failure = continue
  }


  connection {
    type   	 = "ssh"
    user    	 = "ec2-user"
    private_key  = file("C:/Users/Vimal Daga/Downloads/key_aws_training_2022.pem")
    host    	 = aws_instance.myweb.public_ip
  }

  depends_on = [
    aws_volume_attachment.ebs_att,
  ]


}


resource "null_resource" "nulllocal2" {
  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Destroy-time ....'"
  }
}


output "public_ip" {
	value = aws_instance.myweb.public_ip
}


resource "null_resource" "nulllocalchrome" {
  provisioner "local-exec" {
    command = "chrome ${aws_instance.myweb.public_ip}"
  }

 depends_on = [
    null_resource.nullremote1,
  ]

}


