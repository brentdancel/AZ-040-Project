<#
- This script increases the Windows Paging file initial and maximum sizes on the C: drive

- Run this script if...
        You frequently run out of RAM
        *Applications crash out with out-of-memory errors
        *You run memory-intensive applications, VMs, or have many browser tabs
        Windows report low virutal memory

!!!!!!INCREASING PAGING FILE PROVDIES MORE VRAM, BUT IT DOES NOT REPLACE ADDING PHYSICAL RAM!!!!!!!
#>

# Disabling automatic management of the Paging file sizes
Get-CimInstance -ClassName Win32_ComputerSystem | Set-CimInstance -Property @{AutomaticManagedPagefile = $false}

# Gathering how much installed RAM(MB) workstation has
$totalRamMB = Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum | ForEach-Object {$_.Sum / 1MB}

# Gathering current Windows Paging File Settings on C drive
$currentSize = Get-CimInstance -ClassName Win32_PageFileSetting | Where-Object {$_.Name -eq 'C:\pagefile.sys'}

# Increasing Windows Paging File Initial Size by multiplying installed RAM(MB) by 1.5 and set it to that result
$initialSize = $totalRamMB * 1.5

# Increasing Windows Paging File Maximum Size by multiplying installed RAM(MB) by 3 and set it to that result
$maxSize = $totalRamMB * 3

# Verify if sizes are already set to recommended settings
# If not, set the sizes to the recommended settings
if ($currentSize.InitialSize -eq $initialSize -and $currentSize.MaximumSize -eq $maxSize) {
        Write-Host "The Windows Paging File Sizes are already set to the recommended settings" -ForegroundColor Green
} else {
        Write-Host "The Windows Paging File Sizes are not set to the recommended settings. Setting them now..." -ForegroundColor Green
        Set-CimInstance -InputObject $currentSize -Property @{InitialSize = $initialSize; MaximumSize = $maxSize}
}

# Gathering new Windows Paging File Statistics
$newWinPagFile = Get-CimInstance -ClassName Win32_PageFileSetting | Where-Object { $_.Name -eq 'C:\pagefile.sys' } |Select-Object Name, InitialSize, MaximumSize

# Final Interface
Write-Host "This script has increased the Windows Paging File Sizes for the C drive" -ForegroundColor Green
Write-Host "" -ForegroundColor Green
Write-Host "#### New Windows Paging File Initial Size : $($newWinPagFile.InitialSize)   ###############" -ForegroundColor Green
Write-Host "#### New Windows Paging File Initial Size: $($newWinPagFile.MaximumSize)   ###############" -ForegroundColor Green
Write-Host "" -ForegroundColor Green
Write-Host "Please restart your computer at your convenience." -ForegroundColor Green