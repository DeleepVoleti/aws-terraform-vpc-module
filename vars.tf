variable "cidr" {
    type = string
}

variable "common_tags" {
    type = map
}

variable "project_name" {
    type = string
}

variable "env" {
    type = string
}

variable "public_subnet_cidrs" {
  type = list 

    validation {
        condition = length(var.public_subnet_cidrs) == 2
        error_message = "please provide 2 valid public_subnet_cidrs"  
    }
}

variable "private_subnet_cidrs" {
  type = list 

    validation {
        condition = length(var.private_subnet_cidrs) == 2
        error_message = "please provide 2 valid private_subnet_cidrs"  
    }
}

variable "db_subnet_cidrs" {
  type = list 

    validation {
        condition = length(var.db_subnet_cidrs) == 2
        error_message = "please provide 2 valid db_subnet_cidrs"  
    }
}


# peering variables


variable "is_peering_req" {
    type = bool
  
}

variable "vpc_acceptor_id" {
    type = string
    default = ""
}