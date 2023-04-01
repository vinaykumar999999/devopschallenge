resource "aws_instance" "ec2_instance" {
  ami                    = "ami-006e00d6ac75d2ebb"
  subnet_id              = "subnet-5391370c"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = var.ec2_instance_shh_key
  ebs_optimized          = "false"
  source_dest_check      = "false"
  user_data              = data.template_file.user_date.rendered
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "10"
    delete_on_termination = "true"
  }

  tags = {
    Name = "ec2-instance-security-group-${var.enviroment}"
  }

  depends_on = [aws_key_pair.key]
}

data "template_file" "user_date" {
  template = file("user_data.tpl")
}

resource "aws_key_pair" "key" {
  key_name   = var.ec2_instance_shh_key
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "KEY" {
  content  = tls_private_key.rsa.private_key_pem
  filename = var.ec2_instance_shh_key
}

resource "aws_security_group" "ec2" {
  name        = "ec2-instance-security-group-${var.enviroment}"
  description = "ec2-instance-security-group-${var.enviroment}"
  vpc_id      = "vpc-374dbb4a"

  ingress {
    protocol    = "-1"
    from_port   = "0"
    to_port     = "0"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = "0"
    to_port     = "0"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-instance-security-group-${var.enviroment}"
  }
}