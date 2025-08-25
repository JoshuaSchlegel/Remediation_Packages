<#
.SYNOPSIS
    This PowerShell script ensures that the display of slide shows on the lock screen is disabled.

.NOTES
    Author          : Joshua Schlegel
    LinkedIn        : linkedin.com/in/joshuaschlegel/
    GitHub          : github.com/joshuaschlegel
    Date Created    : 2025-08-24
    Last Modified   : 2025-08-24
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000010

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-CC-000010.ps1 
#>

# Define the registry path and value for the policy
$RegPath = "HKLM:\Software\Policies\Microsoft\Windows\Personalization"
$RegName = "NoLockScreenSlideshow"
$RegValue = 1  # 1 means Enabled

# Check if the registry path exists, and create it if it doesn't
if (-not (Test-Path -Path $RegPath)) {
    New-Item -Path $RegPath -Force
}

# Set the registry value to enable the policy
Set-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue

# Output a message indicating the operation is complete
Write-Host "Policy 'Prevent enabling lock screen slide show' has been set to 'Enabled'."
gpupdate /force
