resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = var.azs[(tonumber(regex("[0-9]+", each.key)) - 1) % length(var.azs)]

  map_public_ip_on_launch = each.value.type == "public"

  tags = {
    Name = "${each.key}"
    Type = "${each.value.type}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${aws_vpc.this.tags["Name"]}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${aws_vpc.this.tags["Name"]}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = { for k, v in aws_subnet.this : k => v if v.tags["Type"] == "public" }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}