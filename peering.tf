# vpc peering 

resource "aws_vpc_peering_connection" "main" {
    count = var.is_peering_req ? 1 : 0
  peer_vpc_id   = local.acceptor_id
  vpc_id        = aws_vpc.main.id
  auto_accept = var.vpc_acceptor_id == "" ? true : false 

  tags = merge ( var.common_tags ,
    {
        Name = " ${ var.project_name}-${var.env} "
    }
    
  )
}

resource "aws_route" "public_peering" {
    count = var.is_peering_req && var.vpc_acceptor_id == "" ? 1 : 0 
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main[0].id
}



resource "aws_route" "private_peering" {
    count = var.is_peering_req && var.vpc_acceptor_id == "" ? 1 : 0 
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main[0].id
}



resource "aws_route" "db_peering" {
    count = var.is_peering_req && var.vpc_acceptor_id == "" ? 1 : 0 
  route_table_id            = aws_route_table.db.id
  destination_cidr_block    = data.aws_vpc.default_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main[0].id
}


resource "aws_route" "default_vpc_peering" {
    count = var.is_peering_req && var.vpc_acceptor_id == "" ? 1 : 0 
  route_table_id            = data.aws_vpc.default_vpc.main_route_table_id
  destination_cidr_block    = aws_vpc.main.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main[0].id
}