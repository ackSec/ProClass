resource "aws_vpc" "classVPC" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "ClassVPC"
        Use  = "Student"
    }
}

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.classVPC.id}"
}

/*
  Public Subnet
*/
resource "aws_subnet" "public" {
    vpc_id = "${aws_vpc.classVPC.id}"
    count = "${var.num_students}"
    cidr_block = "${element(var.public_subnet_list, count.index)}"
    availability_zone = "us-west-2a"

    tags {
        Name = "Public Subnet - ${element(var.hacker_name_list, count.index)}"
        Use  = "Student"
    }
}

resource "aws_route_table" "public" {
    vpc_id = "${aws_vpc.classVPC.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags {
        Name = "Public Subnet"
        Use  = "Student"
    }
}

resource "aws_route_table_association" "public" {
    count = "${var.num_students}"
    subnet_id = "${element(aws_subnet.public.*.id,  count.index)}"
    route_table_id = "${aws_route_table.public.id}"
}

/*
  Private Subnet
*/
resource "aws_subnet" "private" {
    vpc_id = "${aws_vpc.classVPC.id}"
    count = "${var.num_students}"
    cidr_block = "${element(var.private_subnet_list, count.index)}"
    availability_zone = "us-west-2a"

    tags {
        Name = "Private Subnet - ${element(var.hacker_name_list, count.index)}"
        Use  = "Student"
    }
}

resource "aws_route_table" "private" {
    vpc_id = "${aws_vpc.classVPC.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags {
        Name = "Private Subnet"
        Use  = "Student"
    }
}

resource "aws_route_table_association" "private" {
    count = "${var.num_students}"
    subnet_id = "${element(aws_subnet.private.*.id,  count.index)}"
    route_table_id = "${aws_route_table.private.id}"
}
/*

VPC Peer route

resource "aws_route_table" "private" {
    vpc_id = "${aws_vpc.classVPC.id}"

    route {
        cidr_block = "172.31.32.0/20"
        vpc_peering_connection_id = "${aws_vpc_peering_connection.primary2secondary.id}"
    }

    tags {
        Name = "VPC Peer"
    }
}

resource "aws_route_table_association" "private" {
    count = "${var.num_students}"
    subnet_id = "${element(aws_subnet.private.*.id,  count.index)}"
    route_table_id = "${aws_route_table.private.id}"
}
*/

/*
  Management Subnet
*/
resource "aws_subnet" "management" {
    vpc_id = "${aws_vpc.classVPC.id}"
    cidr_block = "${var.management_subnet}"
    availability_zone = "us-west-2a"

    tags {
        Name = "Management Subnet"
        Use  = "Student"
    }
}

resource "aws_route_table" "management" {
    vpc_id = "${aws_vpc.classVPC.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags {
        Name = "Management Subnet"
        Use  = "Student"
    }
}

resource "aws_route_table_association" "management" {
    subnet_id = "${aws_subnet.management.id}"
    route_table_id = "${aws_route_table.management.id}"

}

resource "aws_route53_zone_association" "private" {
  zone_id = "Z3MXGP9U26FV33"
  vpc_id  = "${aws_vpc.classVPC.id}"
}
/*

VPC Peer for chef


resource "aws_vpc_peering_connection" "primary2secondary" {
  # Main VPC ID.
  vpc_id = "vpc-17f86470"

  # AWS Account ID. This can be dynamically queried using the
  # aws_caller_identity data resource.
  # https://www.terraform.io/docs/providers/aws/d/caller_identity.html
  peer_owner_id = "${data.aws_caller_identity.current.account_id}"

  # Secondary VPC ID.
  peer_vpc_id = "${aws_vpc.classVPC.id}"

  # Flags that the peering connection should be automatically confirmed. This
  # only works if both VPCs are owned by the same account.
  auto_accept = true
}

resource "aws_route" "primary2secondary" {
  # ID of VPC 1 main route table.
  route_table_id = "rtb-44cdfd23"

  # CIDR block / IP range for VPC 2.
  destination_cidr_block = "10.0.0.0/8"

  # ID of VPC peering connection.
  vpc_peering_connection_id = "${aws_vpc_peering_connection.primary2secondary.id}"
}
/*
resource "aws_route" "secondary2primary" {
  # ID of VPC 2 main route table.
  route_table_id = "${aws_vpc.secondary.main_route_table_id}"

  # CIDR block / IP range for VPC 2.
  destination_cidr_block = "${aws_vpc.primary.cidr_block}"

  # ID of VPC peering connection.
  vpc_peering_connection_id = "${aws_vpc_peering_connection.primary2secondary.id}"
}
*/
