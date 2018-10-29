resource "aws_instance" "kali_external" {
  count                       = "${var.num_students}"
  ami                         = "${var.hosts["kali"]}"
  availability_zone           = "us-west-2a"
  instance_type               = "t2.small"
  key_name                    = "${var.aws_key_name}"
  vpc_security_group_ids      = ["${element(aws_security_group.kali_external.*.id, count.index)}"]
  subnet_id                   = "${element(aws_subnet.public.*.id, count.index)}"
  associate_public_ip_address = false
  source_dest_check           = false

  tags {
    Name = "${element(var.hacker_name_list, count.index)} - Kali External"
    Use  = "Student"
  }
}

resource "aws_route53_record" "kali_external" {
  count   = "${var.num_students}"
  zone_id = "${var.zoneID["private"]}"
  name    = "${element(var.hacker_name_list, count.index)}-kali"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.kali_external.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "win_jumpbox" {
  count   = "${var.num_students}"
  zone_id = "${var.zoneID["private"]}"
  name    = "${element(var.hacker_name_list, count.index)}"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.win_jumpbox.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "win_jumpbox_pub" {
  count   = "${var.num_students}"
  zone_id = "${var.zoneID["public"]}"

  #depends_on = ["aws_eip.win_jumpbox"]
  name    = "${element(var.hacker_name_list, count.index)}"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.win_jumpbox.*.public_ip, count.index)}"]
}

/*
resource "aws_eip" "win_jumpbox" {
    count = "${var.num_students}"
    instance = "${element(aws_instance.win_jumpbox.*.id, count.index)}"
    vpc = true
}
*/

resource "aws_instance" "win_jumpbox" {
  count                       = "${var.num_students}"
  ami                         = "${var.hosts["jumpbox"]}"
  availability_zone           = "us-west-2a"
  instance_type               = "t2.medium"
  key_name                    = "${var.aws_key_name}"
  vpc_security_group_ids      = ["${element(aws_security_group.win_jumpbox.*.id, count.index)}"]
  subnet_id                   = "${element(aws_subnet.public.*.id, count.index)}"
  associate_public_ip_address = true
  source_dest_check           = false

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
  Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  choco install -y x2go
  choco install -y putty.install
  choco install -y openssh -params '"/SSHServerFeature"'
  Remove-Item –path C:\Users\Administrator\Desktop\ -include *.website –recurse

</powershell>
EOF

  provisioner "file" {
    source      = "/Users/jonmedina/Documents/Projects/terraform/Class_Final/win_files/"
    destination = "C:/Users/Administrator/Desktop"

    connection {
      type     = "ssh"
      user     = "Administrator"
      password = "Admin@123"
      agent    = "false"
    }
  }

  provisioner "file" {
    content = <<EOF

   ----Welcome ${element(var.hacker_name_list, count.index)}----


  --You are here (Jump Box) - ${element(var.hacker_name_list, count.index)}.rubuscloud.com - IP: ${self.private_ip}
  --Your hacker workstation - ${element(var.hacker_name_list, count.index)}-kali.rubuscloud.com IP: ${element(aws_instance.kali_external.*.private_ip, count.index)}
  --Your target network - ${element(var.private_subnet_list, count.index)}
  --Your hacked internal box - ${element(var.hacker_name_list, count.index)}-internal.rubuscloud.com - IP: ${element(aws_instance.kali_internal.*.private_ip, count.index)}
EOF

    destination = "C:/Users/Administrator/Desktop/Open Me.txt"

    connection {
      type     = "ssh"
      user     = "Administrator"
      password = "Admin@123"
      agent    = "false"
    }
  }

  tags {
    Name = "${element(var.hacker_name_list, count.index)} - Jump Box"
    Use  = "Student"
  }
}
