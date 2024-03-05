/*==== The VPC ======*/
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    owner = "${var.owner}"
    expire-on = "${var.expire}"
    purpose = "${var.purpose}"
    project = "${var.project}"
    Name = "${var.project}"
  }
}

/*==== Subnets ======*/
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    owner = "${var.owner}"
    expire-on = "${var.expire}"
    purpose = "${var.purpose}"
    project = "${var.project}"
  }
}

/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
}

/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = aws_subnet.public_subnet.id
  depends_on    = [aws_internet_gateway.ig]

  tags = {
    owner = "${var.owner}"
    expire-on = "${var.expire}"
    purpose = "${var.purpose}"
    project = "${var.project}"
    Name = "${var.project}-ngw"
  }
}

/* Public subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.availability_zone}"
  map_public_ip_on_launch = true

  tags = {
    owner = "${var.owner}"
    expire-on = "${var.expire}"
    purpose = "${var.purpose}"
    project = "${var.project}"
    Name = "${var.project}-sn-pblc"
  }
}

/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.availability_zone}"
  map_public_ip_on_launch = false

  tags = {
    owner = "${var.owner}"
    expire-on = "${var.expire}"
    purpose = "${var.purpose}"
    project = "${var.project}"
    Name = "${var.project}-sn-prvt"
  }
}

/* Routing table for public subnet */
resource "aws_default_route_table" "public" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  tags = {
    owner = "${var.owner}"
    expire-on = "${var.expire}"
    purpose = "${var.purpose}"
    project = "${var.project}"
    Name = "${var.project}-rtb-pblc"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    owner = "${var.owner}"
    expire-on = "${var.expire}"
    purpose = "${var.purpose}"
    project = "${var.project}"
    Name = "${var.project}-rtb-prvt"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_default_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.ig.id}"
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_nat_gateway.nat.id}"
}

/* Route table associations */
resource "aws_main_route_table_association" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  route_table_id = "${aws_default_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = "${aws_route_table.private.id}"
}

/*==== VPC's Default Security Group ======*/
resource "aws_security_group" "default" {
  name        = "${var.project}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = "${aws_vpc.vpc.id}"
  depends_on  = [aws_vpc.vpc]

  ingress = [
    {
      description      = "All Ports/Protocols"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  egress = [
    {
      description      = "All Ports/Protocols"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  tags = {
    owner = "${var.owner}"
    expire-on = "${var.expire}"
    purpose = "${var.purpose}"
    project = "${var.project}"
  }
}
