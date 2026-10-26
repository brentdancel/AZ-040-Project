<#
Script gathers key information about the workstation
Afterwards, it displays a warning if the uptime is above 14 days and 
a prompt to investigate if the uptime is above 30 days.
#>

# Gather OS information
$os = Get-CimInstance -ClassName Win32_OperatingSystem

# Gather C drive information
$cDrive = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"

# Calculate uptime in hours
$uptime = $os.LocalDateTime - $os.LastBootUpTime

# Combine properties into a custom object for display
$computerInfo =[PSCustomObject]@{
    BuildNumber = $os.BuildNumber
    Caption = $os.Caption
    OSArchitecture = $os.OSArchitecture
    Version = $os.Version
    User = $os.RegisteredUser
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
if ($uptime.TotalDays -gt 30) {
    Write-Host "Warning: Uptime is above 30 days. Please investigate." -ForegroundColor Red
} elseif ($uptime.TotalDays -gt 14) {
    Write-Host "Notice: Uptime is above 14 days." -ForegroundColor Yellow
} elseif ($uptime.TotalDays -le 14) {
    Write-Host "Uptime is within normal range." -ForegroundColor Green
}