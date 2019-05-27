# Create VPC

resource "aws_vpc" "my-vpc" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "TestVPC"
  }
}

# Create VPC public subnet

resource "aws_subnet" "public_subnet_us_east_1a" {
  vpc_id                  = "${aws_vpc.my-vpc.id}"
  cidr_block              = "172.31.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "Subnet az 1a"
  }
}

# Create VPC private subnets

resource "aws_subnet" "private_1_subnet_us_east_1a" {
  vpc_id            = "${aws_vpc.my-vpc.id}"
  cidr_block        = "172.31.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Subnet private 1 az 1a"
  }
}

resource "aws_subnet" "private_2_subnet_us_east_1b" {
  vpc_id            = "${aws_vpc.my-vpc.id}"
  cidr_block        = "172.31.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Subnet private 2 az 1b"
  }
}

resource "aws_subnet" "private_3_subnet_us_east_1c" {
  vpc_id            = "${aws_vpc.my-vpc.id}"
  cidr_block        = "172.31.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Subnet private 2 az 1c"
  }
}

# Create Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.my-vpc.id}"

  tags {
    Name = "InternetGateway"
  }
}

# Create route to the internet

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.my-vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

# Create Elastic IP (EIP)

resource "aws_eip" "tuto_eip1" {
  vpc        = true
  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_eip" "tuto_eip2" {
  vpc        = true
  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_eip" "tuto_eip3" {
  vpc        = true
  depends_on = ["aws_internet_gateway.gw"]
}

# Create NAT Gateway

resource "aws_nat_gateway" "nat1" {
  allocation_id = "${aws_eip.tuto_eip1.id}"
  subnet_id     = "${aws_subnet.private_1_subnet_us_east_1a.id}"
  depends_on    = ["aws_internet_gateway.gw"]
}

resource "aws_nat_gateway" "nat2" {
  allocation_id = "${aws_eip.tuto_eip2.id}"
  subnet_id     = "${aws_subnet.private_2_subnet_us_east_1b.id}"
  depends_on    = ["aws_internet_gateway.gw"]
}

resource "aws_nat_gateway" "nat3" {
  allocation_id = "${aws_eip.tuto_eip3.id}"
  subnet_id     = "${aws_subnet.private_3_subnet_us_east_1c.id}"
  depends_on    = ["aws_internet_gateway.gw"]
}

# Create private route table and the route to the internet
resource "aws_route_table" "private_route_table1" {
  vpc_id = "${aws_vpc.my-vpc.id}"

  tags {
    Name = "Private route table"
  }
}

resource "aws_route_table" "private_route_table2" {
  vpc_id = "${aws_vpc.my-vpc.id}"

  tags {
    Name = "Private route table"
  }
}

resource "aws_route_table" "private_route_table3" {
  vpc_id = "${aws_vpc.my-vpc.id}"

  tags {
    Name = "Private route table"
  }
}

resource "aws_route" "private_route" {
  route_table_id         = "${aws_route_table.private_route_table1.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat1.id}"
}

resource "aws_route" "private_route2" {
  route_table_id         = "${aws_route_table.private_route_table2.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat2.id}"
}

resource "aws_route" "private_route3" {
  route_table_id         = "${aws_route_table.private_route_table3.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat3.id}"
}

# Create Route Table Associations

# Associate subnet public_subnet_us_east_1a to public route table
resource "aws_route_table_association" "public_subnet_us_east_1a_association" {
  subnet_id      = "${aws_subnet.public_subnet_us_east_1a.id}"
  route_table_id = "${aws_vpc.my-vpc.main_route_table_id}"
}

# Associate subnet private_1_subnet_us_east_1a to private route table
resource "aws_route_table_association" "pr_1_subnet_us_east_1a_association" {
  subnet_id      = "${aws_subnet.private_1_subnet_us_east_1a.id}"
  route_table_id = "${aws_route_table.private_route_table1.id}"
}

# Associate subnet private_2_subnet_us_east_1a to private route table
resource "aws_route_table_association" "pr_2_subnet_us_east_1a_association" {
  subnet_id      = "${aws_subnet.private_2_subnet_us_east_1b.id}"
  route_table_id = "${aws_route_table.private_route_table2.id}"
}

resource "aws_route_table_association" "pr_3_subnet_us_east_1a_association" {
  subnet_id      = "${aws_subnet.private_3_subnet_us_east_1c.id}"
  route_table_id = "${aws_route_table.private_route_table3.id}"
}
