resource "aws_vpc" "main" {
    cidr_block = var.cidr
    enable_dns_hostnames = true

    tags = merge(
        var.common_tags ,
        {
        Name = local.name
        }
    )
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = merge(
        var.common_tags ,
        {
            Name = "internet-gateway"
        }
    )
}


resource "aws_subnet" "public" {
    vpc_id = aws_vpc.main.id
    count = length(var.public_subnet_cidrs)
    cidr_block = var.public_subnet_cidrs[count.index]
    availability_zone = data.aws_availability_zones.az_data.names[count.index]
    map_public_ip_on_launch = true

    tags = merge(
        var.common_tags,
        {
            Name = "${var.project_name}-${var.env}-public-${local.az_names[count.index]}"
        }
    )
}


resource "aws_subnet" "private" {
    vpc_id = aws_vpc.main.id
    count = length(var.private_subnet_cidrs)
    cidr_block = var.private_subnet_cidrs[count.index]
    availability_zone = data.aws_availability_zones.az_data.names[count.index]
    map_public_ip_on_launch = false  #however the default value is false

    tags = merge(
        var.common_tags,
        {
            Name = "${var.project_name}-${var.env}-private-${local.az_names[count.index]}"
        }
    )
}


resource "aws_subnet" "db" {
    vpc_id = aws_vpc.main.id
    count = length(var.db_subnet_cidrs)
    cidr_block = var.db_subnet_cidrs[count.index]
    availability_zone = data.aws_availability_zones.az_data.names[count.index]
    map_public_ip_on_launch = false

    tags = merge(
        var.common_tags,
        {
            Name = "${var.project_name}-${var.env}-db-${local.az_names[count.index]}"
        }
    )
}

#ellastic ip

resource "aws_eip" "main" {
domain = "vpc"

  tags = {
    Name = "dilips-ellastic-ip"
  }
}

# nat gateway 

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "dilips-nat-gateway"
  }

  
  depends_on = [aws_internet_gateway.main]
}

# Route table

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

  tags = {
    Name = "Public-route-table"
  }
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table" "db" {
    vpc_id = aws_vpc.main.id

  tags = {
    Name = "db-route-table"
  }
}


# Routes

resource "aws_route" "Public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id  = aws_nat_gateway.main.id
}

resource "aws_route" "db" {
  route_table_id            = aws_route_table.db.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id  = aws_nat_gateway.main.id
}


# assosiating route table to respective subnets

resource "aws_route_table_association" "public" {
    count = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
    count = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "db" {
    count = 2
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db.id
}


#######################################################################################################################################


resource "aws_db_subnet_group" "main" {
  name = local.name
  subnet_ids = aws_subnet.db[*].id

  tags = {
    Name = local.name
  }
}