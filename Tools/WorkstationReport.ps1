<#
Script gathers key information about the workstation
Afterwards, it displays a warning if the uptime is above 14 days and a prompt to investigate if the uptime is above 30 days.
#>

# Gather OS information
$os = Get-CimInstance -ClassName Win32_OperatingSystem
$os.BuildNumber
$os.Caption
$os.OSArchitecture
$os.Version

# Gather C drive information
$cDrive = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"
$cDrive.Size
$cDrive.FreeSpace

# Calculate uptime in hours
$uptime = $os.LocalDateTime - $os.LastBootUpTime
$uptime.Hours

# Combine properties into a custom object for display
$computerInfo =[PSCustomObject]@{
    BuildNumber = $os.BuildNumber
    Caption = $os.Caption
    OSArchitecture = $os.OSArchitecture
    Version = $os.Version
    CDriveSizeGB = [math]::Round($cDrive.Size / 1GB, 2)
    CDriveFreeSpaceGB = [math]::Round($cDrive.FreeSpace / 1GB, 2)
    UptimeHours = [math]::Round($uptime.TotalHours, 2)
}

Write-Host "Workstation Information: " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green
$computerInfo | Format-Table -AutoSize

<#
Flag uptime above 14 days as an informational warning and 
above 30 days as a prompt to investigate—not automatically classify either as a failure.
#>