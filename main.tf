resource "aws_vpc" "devopsola_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "devopsola_subnet" {
  count = length(var.subnet_azs)
  vpc_id = aws_vpc.devopsola_vpc.id
  cidr_block = cidrsubnet(aws_vpc.devopsola_vpc.cidr_block, 8, count.index)
  availability_zone = var.subnet_azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-subnet-${count.index}"
  }
}

resource "aws_route_table" "devopsola_route_table" {
  vpc_id = aws_vpc.devopsola_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devopsola_igw.id
  }

  tags = {
    Name = var.route_table_name
  }
}

resource "aws_eks_cluster" "devopsola" {
  name     = var.eks_cluster_name
  ...
}
