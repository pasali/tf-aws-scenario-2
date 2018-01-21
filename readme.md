# AWS Scenario 2 Terraform Module

This module provides an example implementation of AWS scenario 2 via Terraform.

Example infrastructure consist of:

- 1 production database
- Multiple production/test instances
- 1 Elastic Load Balancer in front of production instances
- 1 test database
- 1 private and 1 public subnet
- 1 NAT instance
- 1 Internet Gateway instance

![](https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/images/nat-gateway-diagram.png)



## Usage

    provider "aws" {
      access_key = ""
      secret_key = ""
      region     = ""
    }
      

    module "infrastructure" {
      source = "modules/infrastructure"
      name = "pasali"
      cidr = "10.0.0.0/16"
      private_subnet_cidr = "10.0.1.0/24"
      public_subnet_cidr = "10.0.2.0/24"
      number_of_test_instances = "1"
      test_instance_type = "t2.micro"
      number_of_prod_instances = "3"
      prod_instance_type = "t2.small"
      dev_db_instance = "${var.dev_db_instance}"
      prod_db_instance = "${var.prod_db_instance}"
      public-file = ".keypair/pasali.pub"
    }
      
    variable "dev_db_instance" {
      type = "map"
      default = {
        rds_instance_name     = "pasali"
        rds_allocated_storage = "10" # GB
        rds_engine_type       = "postgres"
        rds_engine_version    = "9.6.2"
        rds_instance_class    = "db.t2.small"
        database_name         = "pasali"
        database_user         = "pasali"
        database_password     = "pasali123"
        rds_is_multi_az       = "false"
        rds_storage_type      = "standard"
      }
    
    }
    
    variable "prod_db_instance" {
      type = "map"
      default = {
        rds_instance_name     = "pasali-prod"
        rds_allocated_storage = "100" # GB
        rds_engine_type       = "postgres"
        rds_engine_version    = "9.6.2"
        rds_instance_class    = "db.m4.xlarge"
        database_name         = "pasali"
        database_user         = "postgres"
        database_password     = "p4s4l1!p4ss"
        rds_is_multi_az       = "false"
        rds_storage_type      = "standard"
      }
    
    }
       
    output "gateway-id" {
      value = "${module.infrastructure.nat-gateway-ip}"
    }
      
    output "test-ips" {
      value = "${module.infrastructure.test-ips}"
    }
      
    output "prod-ips" {
      value = "${module.infrastructure.prod-ips}"
    }
   
