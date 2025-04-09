data "aws_route53_zone" "devops" {
  name         = "devops.coda.run"
  private_zone = false
}

locals {
  username = split("@", var.email)[0]
}
