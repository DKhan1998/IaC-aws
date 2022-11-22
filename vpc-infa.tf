### VPC SECTION
## VPC for Staging 
resource "aws_vpc" "staging_vpc" {
  cidr_block           = "10.128.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "staging_vpc"
  }
}

## Subnets
resource "aws_subnet" "public_subnet_2a" {
  vpc_id            = aws_vpc.staging_vpc.id
  cidr_block        = "10.128.0.0/24"
  availability_zone = "eu-west-2a"
  tags = {
    Name = "public-subnet-2a"
  }
}

resource "aws_subnet" "public_subnet_2b" {
  vpc_id            = aws_vpc.staging_vpc.id
  cidr_block        = "10.128.10.0/24"
  availability_zone = "eu-west-2b"
  tags = {
    Name = "public-subnet-2b"
  }
}

### INTERNET GW SECTION
## Internet Gateway for APP
resource "aws_internet_gateway" "staging_igw" {
  vpc_id = aws_vpc.staging_vpc.id
  tags = {
    Name = "staging_igw"
  }
}

### ROUTE TABLE SECTION
## Route for APP
resource "aws_route_table" "petclinic_app_rt" {
  vpc_id = aws_vpc.staging_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.staging_igw.id
  }
  tags = {
    Name = "petclinic_app_rt"
    Environment = "staging"
  }
}

## APP Route Table - Subnet Associations
resource "aws_route_table_association" "petclinit_rta" {
  subnet_id      = aws_subnet.public_subnet_2a.id
  route_table_id = aws_route_table.petclinic_app_rt.id
}
resource "aws_route_table_association" "petclinit_rta2" {
  subnet_id      = aws_subnet.public_subnet_2b.id
  route_table_id = aws_route_table.petclinic_app_rt.id
}

### SECURITY GROUPS SECTION
## SG for APP VPC
resource "aws_security_group" "petclinic_app_sg" {
  name        = "petclinic_app_sg"
  description = "EC2 instances security group"
  vpc_id      = aws_vpc.staging_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "Allow SSH from my Public IP"
    cidr_blocks = ["82.27.190.249/32"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    description = "Allow HTTP traffic"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "petclinic_app_sg"
    Environment = "staging"
  }
}

## SG for DB VPC
resource "aws_security_group" "petclinic_db_sg" {
  name        = "petclinic_db_sg"
  description = "Database security group"
  vpc_id      = aws_vpc.staging_vpc.id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    description = "Allow traffic to MySQL Subnet 2A"
    cidr_blocks = ["10.128.0.0/24"]
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    description = "Allow traffic to MySQL Subnet 2B"
    cidr_blocks = ["10.128.10.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "petclinic_db_sg"
    Environment = "staging"
  }
}
