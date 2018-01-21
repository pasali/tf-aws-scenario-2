data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = [
      "hvm"]
  }

  owners = [
    "099720109477"]
  # Canonical
}

resource "aws_instance" "test" {
  ami = "ami-d429faad"
  count = "${var.number_of_test_instances}"
  subnet_id = "${aws_subnet.public.id}"
  instance_type = "${var.test_instance_type}"
  vpc_security_group_ids = [
    "${aws_security_group.api.id}"]
  associate_public_ip_address = true
  key_name = "${aws_key_pair.key_pair.key_name}"

  root_block_device {
    volume_size = 20
  }

  tags {
    builtWith = "terraform"
    Name = "test-api-${count.index}"
  }
}

resource "aws_instance" "prod" {
  # coreos
  ami = "ami-c8a811b1"
  count = "${var.number_of_prod_instances}"
  subnet_id = "${aws_subnet.public.id}"
  instance_type = "${var.prod_instance_type}"
  vpc_security_group_ids = [
    "${aws_security_group.api.id}"
  ]
  associate_public_ip_address = true
  key_name = "${aws_key_pair.key_pair.key_name}"

  root_block_device {
    volume_size = 40
  }

  tags {
    builtWith = "terraform"
    Name = "prod-api-${count.index}"
  }

}

resource "aws_elb" "elb" {
  name = "${var.name}-elb"

  subnets         = ["${aws_subnet.public.id}"]
  security_groups = ["${aws_security_group.api.id}"]
  instances       = ["${aws_instance.prod.*.id}"]

  health_check {
    healthy_threshold = 2
    interval = 30
    target = "TCP:80"
    timeout = 5
    unhealthy_threshold = 2
  }
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}


resource "aws_security_group" "api" {
  name = "vpc_web"
  description = "Allow incoming HTTP connections."

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "${var.public_subnet_cidr}"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    # PostgreSQL
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = [
      "${var.private_subnet_cidr}"]
  }

  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.name}_PROD_SG"
  }
}
