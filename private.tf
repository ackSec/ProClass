resource "aws_instance" "kali_internal" {
    count = "${var.num_students}"
    ami = "${var.hosts["kali"]}"
    availability_zone = "us-west-2a"
    instance_type = "t2.small"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${element(aws_security_group.kali_internal.*.id, count.index)}"]
    subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
    associate_public_ip_address = false
    source_dest_check = false
    tags {
        Name = "${element(var.hacker_name_list, count.index)} - Internal Kali"
    }
}


resource "aws_instance" "internal_server" {
    count = "${var.num_students}"
    ami = "${var.hosts["dns"]}"
    availability_zone = "us-west-2a"
    instance_type = "t2.micro"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${element(aws_security_group.master.*.id, count.index)}"]
    subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
    source_dest_check = false
    tags {
        Name = "${element(var.hacker_name_list, count.index)} - DNS and Mail Server"
        Use  = "Student"
    }
}

resource "aws_instance" "internal_vuln_nix" {
    count = "${var.num_students}"
    ami = "${var.hosts["vuln_nix"]}"
    availability_zone = "us-west-2a"
    instance_type = "t2.small"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${element(aws_security_group.vuln_nix.*.id, count.index)}"]
    subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
    source_dest_check = false

    tags {
        Name = "${element(var.hacker_name_list, count.index)} - Vulnerable Linux Server"
        Use  = "Student"
    }
}


resource "aws_route53_record" "kali_internal" {
  count = "${var.num_students}"
  zone_id = "${var.zoneID["private"]}"
  name = "${element(var.hacker_name_list, count.index)}-internal"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.kali_internal.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "internal_server" {
  count = "${var.num_students}"
  zone_id = "${var.zoneID["private"]}"
  name = "${element(var.hacker_name_list, count.index)}-server"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.internal_server.*.private_ip, count.index)}"]
}

/*

resource "aws_route53_record" "internal_vuln_win" {
  count = "${var.num_students}"
  zone_id = "${var.zoneID["private"]}"
  name = "securifax"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.internal_vuln_win.*.private_ip, count.index)}"]
}
*/
resource "aws_route53_record" "internal_vuln_nix" {
  count = "${var.num_students}"
  zone_id = "${var.zoneID["private"]}"
  name = "${element(var.hacker_name_list, count.index)}-webserver"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.internal_vuln_nix.*.private_ip, count.index)}"]
}



resource "aws_instance" "internal_vuln_win" {
    count = "${var.num_students}"
    ami = "${var.hosts["vuln_win"]}"
    availability_zone = "us-west-2a"
    instance_type = "t2.small"
    key_name = "${var.aws_key_name}"
    /*
    provisioner "file" {
      source      = "/Users/jonmedina/Documents/Projects/terraform/Class_Final/Class/win_files/"
      destination = "C:/Users/Administrator/Desktop"
      connection {
        type     = "winrm"
        user     = "Administrator"
        password = "${var.admin_password}"
      }
    }
    */
    vpc_security_group_ids = ["${element(aws_security_group.win_jumpbox.*.id, count.index)}"]
    subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
    associate_public_ip_address = true
    source_dest_check = false
    user_data = <<EOF
  <powershell>
  net user Administrator Admin@123
  winrm quickconfig -q
  winrm set winrm/config/winrs ‘@{MaxMemoryPerShellMB=”300″}’
  winrm set winrm/config ‘@{MaxTimeoutms=”1800000″}’
  winrm set winrm/config/service ‘@{AllowUnencrypted=”true”}’
  winrm set winrm/config/service/auth ‘@{Basic=”true”}’
  set-service WinRM -StartupType Automatic
  netsh advfirewall firewall add rule name=”WinRM 5985″ protocol=TCP dir=in localport=5985 action=allow
  netsh advfirewall firewall add rule name=”WinRM 5986″ protocol=TCP dir=in localport=5986 action=allow
  netsh advfirewall firewall add rule name=”WinRM 5986″ protocol=TCP dir=in localport=22 action=allow
  netsh advfirewall set allprofiles state off
  net stop winrm
  net start winrm
  </powershell>
EOF
    tags {
        Name = "${element(var.hacker_name_list, count.index)} - Vulnerable Windows"
    }
}
