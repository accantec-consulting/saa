resource "aws_vpc" "saa-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = false
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "SAA-VPC"
  }
}

resource "aws_subnet" "saa-subnet" {
  vpc_id                              = aws_vpc.saa-vpc.id
  assign_ipv6_address_on_creation     = false
  cidr_block                          = "10.0.1.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"

  tags = {
    Name = "SAA-Subnet"
  }
}

resource "aws_route_table" "saa-routetable" {
  vpc_id = aws_vpc.saa-vpc.id

  tags = {
    Name = "SAA-RouteTable"
  }
}

resource "aws_route_table_association" "example" {
  subnet_id      = aws_subnet.saa-subnet.id
  route_table_id = aws_route_table.saa-routetable.id
}

resource "aws_route" "igw-route" {
  route_table_id         = aws_route_table.saa-routetable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.saa-igw.id
}

resource "aws_internet_gateway" "saa-igw" {
  vpc_id = aws_vpc.saa-vpc.id

  tags = {
    Name = "SAA-InternetGateway"
  }
}

resource "aws_security_group" "saa-sg" {
  name        = "SAA-EC2-Streamlit-Frontend-InstanceSecurityGroup"
  description = "SAA Security Group"
  vpc_id      = aws_vpc.saa-vpc.id

  tags = {}
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.saa-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_tcp_ipv4_port22" {
  security_group_id = aws_security_group.saa-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_tcp_ipv4_port443" {
  security_group_id = aws_security_group.saa-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_tcp_ipv4_port80" {
  security_group_id = aws_security_group.saa-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_tcp_ipv4_port8501" {
  security_group_id = aws_security_group.saa-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 8501
  to_port           = 8501
}
