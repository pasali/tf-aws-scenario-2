variable "cidr" {
  default = ""
}

variable "name" {
  default = ""
}

variable "public_subnet_cidr" {
  default = ""
}

variable "private_subnet_cidr" {
  default = ""
}

variable "number_of_test_instances" {
  default = ""
}
variable "test_instance_type" {
  default = ""
}

variable "number_of_prod_instances" {
  default = ""
}

variable "prod_instance_type" {
  default = ""
}


variable "dev_db_instance" {
  type = "map"
  default = {
    rds_instance_name     = ""
    rds_allocated_storage = ""
    rds_engine_type       = ""
    rds_engine_version    = ""
    rds_instance_class    = ""
    database_name         = ""
    database_user         = ""
    database_password     = ""
    rds_is_multi_az       = ""
    rds_storage_type      = ""
  }
}

variable "prod_db_instance" {
  type = "map"
  default = {
    rds_instance_name     = ""
    rds_allocated_storage = ""
    rds_engine_type       = ""
    rds_engine_version    = ""
    rds_instance_class    = ""
    database_name         = ""
    database_user         = ""
    database_password     = ""
    rds_is_multi_az       = ""
    rds_storage_type      = ""
  }
}

variable "public-file" {
  default = ""
}
