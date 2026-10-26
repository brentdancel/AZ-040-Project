<#
Powershell script for creating user accounts and adding it to AD
Original Author: Adam Bertram

The original script was created by Adam Bertram
I have modified the script for my own use
#>

<#Parameters required input#>
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$FirstName,

    [Parameter(Mandatory)]
    [string]$LastName,

    [Parameter(Mandatory)]
    [string]$Department
)

# Install the Active Directory module if it is not already installed
Install-Module -Name ActiveDirectory -Force -Scope CurrentUser -Confirm:$false

<# The while loop verifies if a username is already taken or not#>
try {
    $i = 2
    while ((Get-ADUser -Filter "samAccountName -eq '$userName'") -and
    ($userName -notlike "$FirstName*")) {
        Write-Warning -Message "The username [$($userName)] already exists. Trying another..."
        $userName = '{0}{1}' -f $FirstName.Substring(0,$i)
        Start-Sleep -Seconds 1
        $i++
    }

<# The if/elseif statements checks for the OU and group#>
    if (-not ($ou = Get-ADOrganizationalUnit -Filter "Name -eq '$Department'")) {
        throw "The Active Directory OU for department [$($Department)] could not be found."
    } elseif (-not (Get-ADGroup -Filter "Name -eq '$Department'")){
        throw "The group [$($Department)] does not exist."        
    }

<# This generates a randomly generated password for the inital account #>
<# You can change the minimum and maximum characters, depending on organizational needs #>
    Add-Type -AssemblyName 'System.Web'
    $password = [System.Web.Security.Membership]::GeneratePassword(
        (Get-Random Minimum 20 -Maximum 32), 3)
    $secPw = ConvertTo-SecureString -String $password -AsPlainText -Force


<# After getting all the parameters, we can now pass the variables into the NewADUser Cmdlet#>
    $newUserParams = @{
        GivenName = $FirstName
        EmployeeName = $EmployeeNumber
        Surname = $LastName
        Name = $userName
        AccountPassword = $secPw
        ChangePasswordAtLogon = $true
        Enabled = $true
        Department = $Department
        Path = $ou.DistinguishedName
        Confirm = $false
    }
    New-ADuser @newUserParams
    Add-ADGroupMember -Identity $Department -Members $userName
     
} catch {
    Write-Error -Message $_.Exception.Message
}