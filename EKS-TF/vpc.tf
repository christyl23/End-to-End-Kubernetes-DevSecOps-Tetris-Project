data "aws_vpc" "dove" {
  filter {
    name   = "tag:Name"
    values = [var.vpc-name]
  }
}

data "aws_internet_gateway" "dove-IGW" {
  filter {
    name   = "tag:Name"
    values = [var.igw-name]
  }
}

data "aws_subnet" "dove-pub-1" {
  filter {
    name   = "tag:Name"
    values = [var.subnet-name]
  }
}

data "aws_security_group" "dove-sg" {
  filter {
    name   = "tag:Name"
    values = [var.security-group-name]
  }
}

resource "aws_subnet" "dove-pub-2" {
  vpc_id                  = data.aws_vpc.dove.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "dove-pub-2"
  }
}

resource "aws_route_table" "dove-pub-RT" {
  vpc_id = data.aws_vpc.dove.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.dove-IGW.id
  }

  tags = {
    Name = "dove-pub-RT"
  }
}

resource "aws_route_table_association" "dove-pub-1-a" {
  route_table_id = aws_route_table.dove-pub-RT.id
  subnet_id      = aws_subnet.dove-pub-1.id
}