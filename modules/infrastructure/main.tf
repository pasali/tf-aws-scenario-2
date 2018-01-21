resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags {
    builtWith = "terraform"
    Name      = "${var.name}_VPC"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    builtWith = "terraform"
    Name      = "${var.name}_NAT"
  }
}

/*
  Public Subnet
*/
resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.public_subnet_cidr}"
  availability_zone = "eu-west-1a"

  tags {
    Name = "${var.name}_PUB"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "${var.name}_PUB"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

/*
  Private Subnet
*/
resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.private_subnet_cidr}"
  availability_zone = "eu-west-1b"

  tags {
    Name = "${var.name}_PRV"
  }
}

resource "aws_db_subnet_group" "rds" {
  subnet_ids = ["${aws_subnet.public.id}", "${aws_subnet.private.id}"]

}

resource "aws_security_group" "nat" {
  name = "vpc_nat"
  description = "Allow traffic to pass from the private subnet to the internet"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.private_subnet_cidr}"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${var.private_subnet_cidr}"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.cidr}"]
  }
  egress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { # PostgreSQL
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["${var.private_subnet_cidr}"]
  }


  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "NATSG"
  }
}

resource "aws_instance" "nat" {
  ami = "ami-076d5d61" # this is a special ami preconfigured to do NAT
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.key_pair.key_name}"
  vpc_security_group_ids = ["${aws_security_group.nat.id}"]
  subnet_id = "${aws_subnet.public.id}"
  associate_public_ip_address = true
  source_dest_check = false

  tags {
    Name = "VPC NAT"
  }
}
resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.nat.id}"
  }

  tags {
    Name = "${var.name}_PRV"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

resource "aws_key_pair" "key_pair" {
  key_name = "${var.name}_KEY_PAIR"
  public_key = "${file(var.public-file)}"
}
