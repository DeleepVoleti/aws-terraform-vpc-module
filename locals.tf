locals {
    name = "${var.project_name}-${var.env}"
}

locals {
    az_names = slice(data.aws_availability_zones.az_data.names, 0,2)
}

locals {
  acceptor_id = var.vpc_acceptor_id == "" ? data.aws_vpc.default_vpc.id : var.vpc_acceptor_id
}