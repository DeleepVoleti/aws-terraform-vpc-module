data "aws_availability_zones" "az_data" {
  state = "available"
}

data "aws_vpc" "default_vpc" {
  default = true
}