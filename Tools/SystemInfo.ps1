$os = Get-CimInstance -ClassName Win32_OperatingSystem
$os.BuildNumber
$os.Caption
$os.OSArchitecture
$os.Version

$cDrive = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"
$cDrive.Size
$cDrive.FreeSpace

$uptime = $os.LocalDateTime - $os.LastBootUpTime
$uptime.Hours