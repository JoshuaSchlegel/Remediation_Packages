<#
.SYNOPSIS
    This PowerShell script ensures that the maximum size of the Windows Application event log is at least 32768 KB (32 MB).

.NOTES
    Author          : Joshua Schlegel
    LinkedIn        : linkedin.com/in/joshuaschlegel/
    GitHub          : github.com/joshuaschlegel
    Date Created    : 2025-08-23
    Last Modified   : 2025-08-23
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-SO-000030

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-SO-000030.ps1 
#>

# Requires: Admin PowerShell (native on Windows 10)

$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$name    = "SCENoApplyLegacyAuditPolicy"
$value   = 1

# Ensure we're elevated
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    throw "Please run this script in an elevated PowerShell session (Run as Administrator)."
}

# Ensure the Lsa key exists
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Create or update the DWORD
New-ItemProperty -Path $regPath -Name $name -Value $value -PropertyType DWord -Force | Out-Null

# Verify
$current = (Get-ItemProperty -Path $regPath -Name $name).$name
Write-Output "$name is now set to: $current (REG_DWORD)"
