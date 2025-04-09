resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name  = "${local.username}-${var.customer}-vpc"
    Owner = var.email
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr

  tags = {
    Name  = "${local.username}-${var.customer}-main-subnet"
    Owner = var.email
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name  = "${local.username}-${var.customer}-igw"
    Owner = var.email
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {

    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name  = "${local.username}-${var.customer}-rtb-public"
    Owner = var.email
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "me" {
  name        = local.username
  description = "Access for Manny"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from my laptop"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = local.username
    Owner = var.email
  }
}

resource "aws_security_group" "vault" {
  name        = "vault"
  description = "Hashicorp Vault"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 8201
    to_port     = 8201
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH within VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    description = "HTTPS for EDA within VPC"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    description = "Receptor within VPC"
    from_port   = 27199
    to_port     = 27199
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "vault"
    Owner = var.email
  }
}

resource "aws_instance" "vault" {
  count                       = var.vault_count
  ami                         = "ami-0583d8c7a9c35822c"
  associate_public_ip_address = true
  availability_zone           = aws_subnet.main.availability_zone
  instance_type               = "t3.large"
  ipv6_addresses              = []
  key_name                    = var.keyname
  subnet_id                   = aws_subnet.main.id
  tags = {
    Name  = "${var.customer}-vault-${count.index + 1}"
    Owner = var.email
  }
  vpc_security_group_ids = [aws_security_group.vault.id, aws_security_group.me.id]
  root_block_device {
    delete_on_termination = true
    encrypted             = true
    iops                  = 3000
    kms_key_id            = "arn:aws:kms:us-east-1:853973692277:key/19008ab6-3d44-4b37-9c2b-bdcc09df76b1"
    tags                  = {}
    tags_all              = {}
    throughput            = 125
    volume_size           = 20
    volume_type           = "gp3"
  }
}

resource "aws_eip" "vault" {

  count    = var.vault_count
  instance = aws_instance.vault[count.index].id
  domain   = "vpc"

  tags = {
    Name  = "${var.customer}-vault-${count.index + 1}"
    Owner = var.email
  }
}

resource "aws_route53_record" "vault" {
  zone_id = data.aws_route53_zone.devops.zone_id
  name    = "${var.customer}-vault"
  type    = "A"
  ttl     = 300
  records = tolist(aws_eip.vault[*].public_ip)
}

output "vault" {
  description = "The Public DNS for the vault"
  value       = aws_eip.vault[*].public_dns
}
