# VPC
resource "aws_vpc" "vpn-network" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "private_network_vpc"
  }
}