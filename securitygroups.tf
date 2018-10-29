/*
Kali_External SG
*/

resource "aws_security_group" "kali_external" {
    count = "${var.num_students}"
    name = "kali_ext-${count.index}"
    description = "Kali External SG"
    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["${var.management_subnet}"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    vpc_id = "${aws_vpc.classVPC.id}"

    tags {
        Name = "${element(var.hacker_name_list, count.index)} - Vulnerable Linux"
        Use  = "Student"
    }
}

/*
Windows Jumpbox SG
*/

resource "aws_security_group" "win_jumpbox" {
    count = "${var.num_students}"
    name = "win_jb - ${count.index}"
    description = "Windows Jumpbox SG"
    ingress {
        from_port = 3389
        to_port = 3389
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    # WinRM access from anywhere
    ingress {
        from_port   = 5985
        to_port     = 5985
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 5986
        to_port     = 5986
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["${var.management_subnet}"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["${element(var.private_subnet_list, count.index)}"]
        #cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["${element(var.public_subnet_list, count.index)}"]
        #cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.classVPC.id}"

    tags {
        Name = "${element(var.hacker_name_list, count.index)} - Windows Jumpbox"
        Use  = "Student"
    }
}

resource "aws_security_group" "management" {
    name = "Class Management SG"
    description = "Allow management to all"
/*


TODO add SG 10


*/
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["35.165.218.137/32"]
    }

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${var.vpc_cidr}"]
    }

    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.classVPC.id}"

    tags {
        Name = "Management SG"
        Use  = "Student"
    }
}

/*
  DNS server, Vuln Windows Server, Kali Internal
*/

resource "aws_security_group" "master" {
    count = "${var.num_students}"
    name = "master-${count.index}"
    description = "Master Security Group"
    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["${element(var.private_subnet_list, count.index)}"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["${element(aws_instance.win_jumpbox.*.private_ip, count.index)}/32"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["${var.management_subnet}"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.classVPC.id}"

    tags {
        Name = "${element(var.hacker_name_list, count.index)} - Master Internal"
        Use  = "Student"
    }
}

/*
Vulnerable Linux Server
*/

resource "aws_security_group" "vuln_nix" {
    count = "${var.num_students}"
    name = "vuln_nix-${count.index}"
    description = "Vulnerable Linux Machine"
    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["${element(var.private_subnet_list, count.index)}"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["${element(aws_instance.win_jumpbox.*.private_ip, count.index)}/32"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["${var.management_subnet}"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["${element(aws_instance.kali_external.*.private_ip, count.index)}/32"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    vpc_id = "${aws_vpc.classVPC.id}"

    tags {
        Name = "${element(var.hacker_name_list, count.index)} - Vulnerable Linux"
        Use  = "Student"
    }
}

resource "aws_security_group" "kali_internal" {
    count = "${var.num_students}"
    name = "kali_int-${count.index}"
    description = "Internal Kali Machine"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        #cidr_blocks = ["${element(aws_instance.win_jumpbox.*.private_ip, count.index)}/32"]
    }

    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["${element(var.public_subnet_list, count.index)}"]
    }

    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["${element(var.private_subnet_list, count.index)}"]
    }

    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["${var.management_subnet}"]
    }
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    vpc_id = "${aws_vpc.classVPC.id}"

    tags {
        Name = "${element(var.hacker_name_list, count.index)} - Kali Internal"
        Use  = "Student"
    }
}
