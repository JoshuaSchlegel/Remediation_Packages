<#
.SYNOPSIS
    This PowerShell script ensures that the system is configured to prevent the storage of the LAN Manager hash of passwords.

.NOTES
    Author          : Joshua Schlegel
    LinkedIn        : linkedin.com/in/joshuaschlegel/
    GitHub          : github.com/joshuaschlegel
    Date Created    : 2025-08-23
    Last Modified   : 2025-08-23
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-SO-000195

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-SO-000195.ps1 
#>

# Run as Administrator

$path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
$name = 'NoLMHash'
$target = 1

# Ensure the key exists
New-Item -Path $path -Force | Out-Null

# Read current value (if it exists)
try {
    $current = Get-ItemPropertyValue -Path $path -Name $name -ErrorAction Stop
} catch { $current = $null }

# Audit
if ($current -eq $target) {
    Write-Host "COMPLIANT: $name is already set to $target."
    exit 0
} else {
    Write-Host "NON-COMPLIANT: $name is $current (expected $target). Remediating..."
}

# Enforce value
Set-ItemProperty -Path $path -Name $name -Type DWord -Value $target

# Re-verify
$verify = Get-ItemPropertyValue -Path $path -Name $name
if ($verify -eq $target) {
    Write-Host "REMEDIATED: $name successfully set to $target."
    exit 0
} else {
    Write-Error "FAILED: Could not set $name to $target."
    exit 2
}
