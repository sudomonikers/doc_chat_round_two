resource "aws_vpc" "doc_search_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "doc_search_vpc"
  }
}

resource "aws_subnet" "doc_search_vpc" {
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.doc_search_vpc.id
  availability_zone = "${local.region}a"
  tags = {
    Name = "doc_search_vpc-subnet"
  }
}

resource "aws_internet_gateway" "doc_search_vpc" {
  vpc_id = aws_vpc.doc_search_vpc.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.doc_search_vpc.id
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.doc_search_vpc.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.doc_search_vpc.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "vectorsearch_security_group" {
  name_prefix = "vectorsearch-sg"
  description = "Security group for vectorsearch domain"
  vpc_id      = aws_vpc.doc_search_vpc.id

  # Allow traffic on port 9200 (vectorsearch HTTP) from specific sources
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust this to restrict the source IP ranges
  }

  # Example: Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}