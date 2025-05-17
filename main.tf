provider "aws" {
  region = "us-west-1"
}

resource "aws_vpc" "devopsola_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "devopsola_igw" {
  vpc_id = aws_vpc.devopsola_vpc.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_subnet" "devopsola_subnet" {
  count = length(var.subnet_azs)

  vpc_id                  = aws_vpc.devopsola_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  availability_zone       = var.subnet_azs[count.index]
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

resource "aws_route_table_association" "devopsola_rta" {
  count          = length(var.subnet_azs)
  subnet_id      = aws_subnet.devopsola_subnet[count.index].id
  route_table_id = aws_route_table.devopsola_route_table.id
}

resource "aws_security_group" "devopsola_cluster_sg" {
  name        = "${var.vpc_name}-sg"
  description = "EKS cluster communication"
  vpc_id      = aws_vpc.devopsola_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "${var.vpc_name}-sg"
  }
}

resource "aws_iam_role" "devopsola_cluster_role" {
  name = "${var.eks_cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "devopsola_cluster_role_policy" {
  role       = aws_iam_role.devopsola_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "devopsola" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.devopsola_cluster_role.arn

  vpc_config {
    subnet_ids         = aws_subnet.devopsola_subnet[*].id
    security_group_ids = [aws_security_group.devopsola_cluster_sg.id]
  }

  tags = {
    Name = var.eks_cluster_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.devopsola_cluster_role_policy
  ]
}
