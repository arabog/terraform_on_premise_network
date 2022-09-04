# VPC
resource "aws_vpc" "vpn_network" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "private_network_vpc"
  }
}

# VPGateway
resource "aws_vpn_gateway" "vpn_gw" {
  vpc_id = aws_vpc.vpn_network.id

  tags = {
    Name = "vp_gw"
  }
}

# VPGatewayAttachment
resource "aws_vpn_gateway_attachment" "vpn_attachment" {
  vpc_id         = aws_vpc.vpn_network.id
  vpn_gateway_id = aws_vpn_gateway.vpn_gw.id
}

# az
data "aws_availability_zones" "available" {
  state = "available"
}

#privatesubnet1: is AZ not needed to be stated since it't optnal
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.vpn_network.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_subnet_1"
  }
}

#privatesubnet2
resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.vpn_network.id
  availability_zone       = data.aws_availability_zones.available.names[1]
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_subnet_2"
  }
}

# routetable1
resource "aws_route_table" "vpn_network_rt_1" {
  vpc_id = aws_vpc.vpn_network.id

  tags = {
    Name = "route_table_1"
  }
}

# route
resource "aws_route" "private_route_1" {
  route_table_id         = aws_route_table.vpn_network_rt_1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_vpn_gateway.vpn_gw.id
}

# route attachment
resource "aws_route_table_association" "rt_attachment_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.vpn_network_rt_1.id
}

# routetable2
resource "aws_route_table" "vpn_network_rt_2" {
  vpc_id = aws_vpc.vpn_network.id

  tags = {
    Name = "route_table_2"
  }
}

# route
resource "aws_route" "private_route_2" {
  route_table_id         = aws_route_table.vpn_network_rt_2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_vpn_gateway.vpn_gw.id
}

# route attachment
resource "aws_route_table_association" "rt_attachment_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.vpn_network_rt_2.id
}

# vpn connection
resource "aws_vpn_connection" "vpn_connection" {
  customer_gateway_id = aws_customer_gateway.customer_gateway.id
  type                = aws_customer_gateway.customer_gateway.type
  static_routes_only  = true
  vpn_gateway_id      = aws_vpn_gateway.vpn_gw.id

  tags = {
    Name = "vpn_connection"
  }
}

resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn    = 65000
  ip_address = "1.2.3.4"
  type       = "ipsec.1"

  tags = {
    Name = "customer_gateway"
  }
}