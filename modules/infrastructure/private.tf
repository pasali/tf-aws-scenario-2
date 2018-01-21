resource "aws_security_group" "db" {
  name = "vpc_db"
  description = "Allow incoming database connections."

  ingress {
    # PostgreSQL
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.api.id}",
      "${aws_security_group.nat.id}"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = [
      "${var.cidr}"]
  }

  egress {
    from_port = 80
    to_port = 80
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
    Name = "DBServerSG"
  }
}


resource "aws_db_instance" "dev_db" {
  identifier = "${var.dev_db_instance["rds_instance_name"]}"
  allocated_storage = "${var.dev_db_instance["rds_allocated_storage"]}"
  engine = "${var.dev_db_instance["rds_engine_type"]}"
  engine_version = "${var.dev_db_instance["rds_engine_version"]}"
  instance_class = "${var.dev_db_instance["rds_instance_class"]}"
  name = "${var.dev_db_instance["database_name"]}"
  username = "${var.dev_db_instance["database_user"]}"
  password = "${var.dev_db_instance["database_password"]}"

  // Because we're assuming a VPC, we use this option, but only one SG id
  vpc_security_group_ids = [
    "${aws_security_group.db.id}"]
  // We want the multi-az setting to be toggleable, but off by default
  multi_az = "${var.dev_db_instance["rds_is_multi_az"]}"
  storage_type = "${var.dev_db_instance["rds_storage_type"]}"
  db_subnet_group_name = "${aws_db_subnet_group.rds.name}"
  backup_window = "06:30-07:30"
  backup_retention_period = "2"

  skip_final_snapshot = true
}

resource "aws_db_instance" "prod_db" {
  identifier        = "${var.prod_db_instance["rds_instance_name"]}"
  allocated_storage = "${var.prod_db_instance["rds_allocated_storage"]}"
  engine            = "${var.prod_db_instance["rds_engine_type"]}"
  engine_version    = "${var.prod_db_instance["rds_engine_version"]}"
  instance_class    = "${var.prod_db_instance["rds_instance_class"]}"
  name              = "${var.prod_db_instance["database_name"]}"
  username          = "${var.prod_db_instance["database_user"]}"
  password          = "${var.prod_db_instance["database_password"]}"

  // Because we're assuming a VPC, we use this option, but only one SG id
  vpc_security_group_ids = ["${aws_security_group.db.id}"]

  // We want the multi-az setting to be toggleable, but off by default
  multi_az     = "${var.prod_db_instance["rds_is_multi_az"]}"
  storage_type = "${var.prod_db_instance["rds_storage_type"]}"
  db_subnet_group_name = "${aws_db_subnet_group.rds.name}"


  backup_window           = "06:30-07:30"
  backup_retention_period = "2"

  skip_final_snapshot = true
}
