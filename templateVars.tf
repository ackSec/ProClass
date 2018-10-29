data "template_file" "win_user_data" {
  template = "WinUserData.tpl"
  vars {
    hostname = "jumpbox${count.index}"
  }

}

data "template_file" "kali_user_data" {
  template = "KaliUserData.tpl"
  vars {
    cluster = "kali"
  }

}

data "template_file" "mgmt_user_data" {
  template = "MGMTUserData.tpl"
  vars {
    cluster = "mgmt"
  }

}

data "template_file" "win_init" {
    /*template = "${file("user_data")}"*/
    template =<<EOF
  winrm quickconfig -q & winrm set winrm/config/winrs @{MaxMemoryPerShellMB="300"} & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"}


  netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
  $admin = [ADSI]("WinNT://./administrator, user")
  $admin.SetPassword("${var.admin_password}")
  iwr -useb https://omnitruck.chef.io/install.ps1 | iex; install -project chefdk -channel stable -version 0.16.28

EOF

    vars {
      admin_password = "${var.admin_password}"
    }
}
