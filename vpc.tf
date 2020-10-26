# one vpc to hold them all, and in the cloud bind them
resource "aws_vpc" "demo" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.infra_name}_vpc"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.demo.id
  count  = length(data.aws_availability_zones.available.names)
  tags = {
    Name = "${var.infra_name}_public_route_table"
  }
}

data "aws_availability_zones" "available" {
}

# create one public subnet per availability zone
resource "aws_subnet" "public" {
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  count                   = length(data.aws_availability_zones.available.names)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.demo.id
  tags = {
    Name = "${var.infra_name}_subnet_pub_${count.index}"
  }
}

# dynamic list of the public subnets created above
data "aws_subnet_ids" "public" {
  depends_on = [aws_subnet.public]
  vpc_id     = aws_vpc.demo.id
  count      = length(data.aws_availability_zones.available.names)
  tags = {
    Name = "${var.infra_name}_subnet_pub_${count.index}"
  }
}

# let vpc talk to the internet - create internet gateway 
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.demo.id
  tags = {
    Name = "${var.infra_name}_igw"
  }
}

# add public gateway to the route table
resource "aws_route" "public" {
  count                  = length(data.aws_availability_zones.available.names)
  gateway_id             = aws_internet_gateway.gw.id
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = element(aws_route_table.public.*.id, count.index)
}

# and associate route table with each subnet
resource "aws_route_table_association" "public" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
}

# create one private subnet per availability zone
resource "aws_subnet" "private" {
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  count                   = length(data.aws_availability_zones.available.names)
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.demo.id
  tags = {
    Name = "${var.infra_name}_subnet_priv_${count.index}"
  }
}

# dynamic list of the private subnets created above
data "aws_subnet_ids" "private" {
  depends_on = [aws_subnet.private]
  vpc_id     = aws_vpc.demo.id
  count      = length(data.aws_availability_zones.available.names)
  tags = {
    Name = "${var.infra_name}_subnet_priv_${count.index}"
  }  
}

# for each of the private ranges, create a "private" route table.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.demo.id
  count  = length(data.aws_availability_zones.available.names)
  tags = {
    Name = "${var.infra_name}_private_route_table"
  }
}

# and associate route table with each subnet
resource "aws_route_table_association" "private" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

# create elastic IP (EIP) to assign it the NAT Gateway 
resource "aws_eip" "demo_eip" {
  count      = length(data.aws_availability_zones.available.names)
  vpc        = true
  depends_on = [aws_internet_gateway.gw]
}

# create NAT Gateways
# make sure to create the nat in a internet-facing subnet (public subnet)
resource "aws_nat_gateway" "demo" {
  count         = length(data.aws_availability_zones.available.names)
  allocation_id = element(aws_eip.demo_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  depends_on    = [aws_internet_gateway.gw]
}

# add a nat gateway to each private subnet's route table
resource "aws_route" "private_nat_gateway_route" {
  count                  = length(data.aws_availability_zones.available.names)
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_route_table.private]
  nat_gateway_id         = element(aws_nat_gateway.demo.*.id, count.index)
}

