<#
This script retrieves the installed applications on a Windows system and displays the top 10 applications that consume the most disk space.
#>

# These paths are where the installed applications are registered in the Windows Registry.
# Setting it equal to uninstallPaths variable so we can use it later in the script
$uninstallPaths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

# After gathering the uninstall paths, we will retrieve the installed applications with the desired properties
$apps = Get-ItemProperty $uninstallPaths | Where-Object { $_.DisplayName -and $_.EstimatedSize -gt 0} | Select-Object DisplayName, Publisher, @{Name = 'SizeGB'; Expression = {[math]::Round($_.EstimatedSize / 1MB, 2)}} | Sort-Object SizeGB -Descending

# After gathering the installed apps, display the top 10 applications
$apps | Select-Object -First 10 | Format-Table -AutoSize


# Possible Additions to the script:
# - How do I get other applications (games, etc.) that are not registered in the registry?