resource "aws_vpc" "dove" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "dove-vpc"
  }
}

resource "aws_internet_gateway" "dove-IGW" {
  vpc_id = aws_vpc.dove.id

  tags = {
    Name = "dove-IGW"
  }
}

resource "aws_subnet" "dove-pub-1" {
  vpc_id                  = aws_vpc.dove.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "dove-pub-1"
  }
}

resource "aws_route_table" "dove-pub-RT" {
  vpc_id = aws_vpc.dove.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dove-IGW.id
  }

  tags = {
    Name = "dove-pub-RT"
  }
}

resource "aws_route_table_association" "dove-pub-1-a" {
  route_table_id = aws_route_table.dove-pub-RT.id
  subnet_id      = aws_subnet.dove-pub-1.id
}

resource "aws_security_group" "dove-sg" {
  vpc_id      = aws_vpc.dove.id
  description = "Allowing Jenkins, Sonarqube, SSH Access"

  ingress = [
    for port in [22, 8080, 9000] : {
      description      = "TLS from VPC"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      ipv6_cidr_blocks = ["::/0"]
      self             = false
      prefix_list_ids  = []
      security_groups  = []
      cidr_blocks      = ["0.0.0.0/0"]
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dove-sg"
  }
}
