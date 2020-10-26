resource "aws_subnet" "db" {
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.demo.id
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  cidr_block        = element(var.db_subnets_cidr, count.index)

  tags = {
    Name = "db-private-${count.index}"
  }
}


resource "aws_eip" "db_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.gw]
}

# create NAT Gateways
# make sure to create the nat in a internet-facing subnet (public subnet)
resource "aws_nat_gateway" "db" {
  allocation_id = aws_eip.db_eip.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  depends_on    = [aws_internet_gateway.gw]
}


resource "aws_route_table" "db" {
  vpc_id = aws_vpc.demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.db.id
  }

  tags = {
    Name = "DB-route-table"
  }
}

resource "aws_route_table_association" "db" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = element(aws_subnet.db.*.id, count.index)
  route_table_id = aws_route_table.db.id
}

# Create RDS subnet group

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = aws_subnet.db.*.id

  tags = {
    Name = "rds_subnet_group"
  }
}

# Create RDS instance 

resource "aws_db_instance" "rds" {
  allocated_storage    = var.rds_storage
  engine               = var.rds_engine
  instance_class       = var.rds_instance_class
  name                 = var.rds_name
  username             = var.rds_username
  password             = var.rds_password
  db_subnet_group_name = "rds_subnet_group"
  skip_final_snapshot = true
  depends_on          = [aws_db_subnet_group.rds_subnet_group]
}