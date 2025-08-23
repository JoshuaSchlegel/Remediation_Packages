<#
.SYNOPSIS
    This PowerShell script ensures that the Windows Defender SmartScreen filter for Microsoft Edge is enabled

.NOTES
    Author          : Joshua Schlegel
    LinkedIn        : linkedin.com/in/joshuaschlegel/
    GitHub          : github.com/joshuaschlegel
    Date Created    : 2025-08-23
    Last Modified   : 2025-08-23
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000250

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-CC-000250.ps1 
#>
# Registry details
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter"
$name    = "EnabledV9"
$value   = 1

# Ensure running as admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    throw "Please run this script in an elevated PowerShell session (Run as Administrator)."
}

# Create registry path if missing
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Create or update the DWORD value
New-ItemProperty -Path $regPath -Name $name -Value $value -PropertyType DWord -Force | Out-Null

# Verify
$current = (Get-ItemProperty -Path $regPath -Name $name).$name
Write-Output "$name is now set to: $current (REG_DWORD)"
