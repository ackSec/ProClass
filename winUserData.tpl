<script>
  @powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
</script>
<powershell>
  # Set Administrator password
  $admin = [adsi]("WinNT://./administrator, user")
  $admin.psbase.invoke("SetPassword", "${password}")

  # Install Screen Resolution at 1920x1080
  choco install -y screen-resolution --params "'/Password:${password}'"

  # Autologon to rdp_local account created by Screen Resolution
  choco install -y autologon
  autologon rdp_local $env:userdomain ${password}
</powershell>
