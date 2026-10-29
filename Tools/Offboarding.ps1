<#
Powershell script for offboarding user accounts and disabling them in AD
#>

# Parameters required input
[CmdletBinding()]
param (
    [string]$FirstName,
    [string]$LastName,
    [string]$Department
)

# Check if the Active Directory module is installed, and install it if not
if (Get-Module -ListAvailable -Name ActiveDirectory) {
    Write-Verbose -Message "The ActiveDirectory module is already installed." -Verbose
} else {
    $operatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
    if ($operatingSystem.ProductType -eq 1) {
        $installation = Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 -ErrorAction Stop
        if ($installation.State -ne 'Installed') {
            throw "Failed to install the Active Directory RSAT capability."
        }
    } else {
        $installation = Install-WindowsFeature -Name RSAT-AD-PowerShell -ErrorAction Stop
        if (-not $installation.Success) {
            throw "Failed to install the Active Directory PowerShell feature."
        }
    }
}

# Prompting for user input if parameters are not provided
if (-not $FirstName) {
    $FirstName = Read-Host -Prompt "Please enter the user's first name"
}
if (-not $LastName) {
    $LastName = Read-Host -Prompt "Please enter the user's last name"
}
if (-not $Department) {
    $Department = Read-Host -Prompt "Please enter the user's department"
}

# Wrapping main code within the try/catch block to handle any errors that may occur during execution
try {

    # The if/elseif statements checks for the OU and group
    # If the OU or group does not exist, it will throw an error and stop the script
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$Department'")) {
        throw "The Active Directory OU for department $($Department) could not be found."
    } elseif (-not (Get-ADGroup -Filter "Name -eq '$Department'")){
        throw "The group [$($Department)] does not exist."
    }

    # Retrieve the Active Directory user
    $user = @(
    Get-ADUser -Filter {
        GivenName -eq $FirstName -and
        Surname -eq $LastName -and
        Department -eq $Department
    } -Properties DisplayName, Department, Enabled -ErrorAction Stop)

    # Checks if the user was found
    if ($user.Count -eq 0) {
        throw "No user found with the name $($FirstName) $($LastName) in the department $($Department)."
    } elseif ($user.Count -gt 1) {
        throw "Multiple users found with the name $($FirstName) $($LastName) in the department $($Department). Please refine your search."
    }

    # Check whether the account is already disabled
    if (-not $user.Enabled) {
        Write-Host "`nThe account [$($user.SamAccountName)] is already disabled." -ForegroundColor Yellow
        return
    } else {
        Disable-ADAccount -Identity $user.DistinguishedName -ErrorAction Stop
    }

    # Verify that the account is disabled
    $updatedUser = Get-ADUser -Identity $user.SamAccountName -Properties Enabled -ErrorAction Stop
    if (-not $updatedUser.Enabled) {
        Write-Host "`nUser account successfully disabled." -ForegroundColor Green
        Write-Host "Username: $($updatedUser.SamAccountName)"
        Write-Host "Account Enabled: $($updatedUser.Enabled)"
    }
    else {
        throw "The account [$($user.SamAccountName)] still appears to be enabled."
    }

} catch {
    Write-Host "Offboarding failed: $_.Exception.Message" -ForegroundColor Red
}