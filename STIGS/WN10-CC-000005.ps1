<#
.SYNOPSIS
    This PowerShell script ensures that camera access from the lock screen is disabled.

.NOTES
    Author          : Joshua Schlegel
    LinkedIn        : linkedin.com/in/joshuaschlegel/
    GitHub          : github.com/joshuaschlegel
    Date Created    : 2025-08-24
    Last Modified   : 2025-08-24
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000005

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-CC-000005.ps1 
#>

Here's a PowerShell script to disable camera access from the lock screen, addressing WN10-CC-000005:

# Check if the script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as Administrator!" -ForegroundColor Red
    exit
}

# Registry path and key for disabling camera access from the lock screen
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
$registryKey = "NoLockScreenCamera"

# Ensure the registry path exists
if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# Set the policy to disable camera access (1 = Disabled)
Set-ItemProperty -Path $registryPath -Name $registryKey -Value 1

# Verify the setting
if ((Get-ItemProperty -Path $registryPath -Name $registryKey).$registryKey -eq 1) {
    Write-Host "Camera access from the lock screen has been successfully disabled." -ForegroundColor Green
} else {
    Write-Host "Failed to disable camera access from the lock screen." -ForegroundColor Red
}
