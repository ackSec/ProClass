/*
resource "aws_instance" "management_instance" {
    ami = "${var.hosts["management"]}"
    #ami = "ami-f14e8989"
    availability_zone = "us-west-2a"
    instance_type = "t2.small"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.management.id}"]
    TODO - add SG10 from original VPC
    subnet_id = "${aws_subnet.management.id}"
    associate_public_ip_address = true
    source_dest_check = false

    tags {
        Name = "Student Management"
        Use  = "Student"
    }
}

resource "aws_eip" "managment_box" {
    instance = "${aws_instance.management_instance.id}"
    vpc = true
}

resource "aws_route53_record" "management_box" {
  zone_id = "${var.zoneID["private"]}"
  name = "studentManagement"
  type = "A"
  ttl = "300"
  records = ["${aws_instance.management_instance.private_ip}"]
}

*/
