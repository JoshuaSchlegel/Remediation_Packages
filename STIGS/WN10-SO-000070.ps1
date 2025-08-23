<#
.SYNOPSIS
    This PowerShell script ensures that the built-in administrator account is disabled.

.NOTES
    Author          : Joshua Schlegel
    LinkedIn        : linkedin.com/in/joshuaschlegel/
    GitHub          : github.com/joshuaschlegel
    Date Created    : 2025-08-23
    Last Modified   : 2025-08-23
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-SO-000070

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-SO-000070.ps1 
#>

# Run as Administrator

$path   = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
$name   = 'InactivityTimeoutSecs'
$target = 900   # change if you want a smaller timeout; must be 1..900

# sanity clamp
if ($target -lt 1 -or $target -gt 900) { $target = 900 }

# ensure key exists
New-Item -Path $path -Force | Out-Null

# read current
try {
    $current = Get-ItemPropertyValue -Path $path -Name $name -ErrorAction Stop
} catch { $current = $null }

# audit
if ($current -is [int] -and $current -ge 1 -and $current -le 900) {
    Write-Host "COMPLIANT: $name is $current seconds."
    exit 0
}

# enforce
Set-ItemProperty -Path $path -Name $name -Type DWord -Value $target

# re-verify
$verify = Get-ItemPropertyValue -Path $path -Name $name
if ($verify -ge 1 -and $verify -le 900) {
    Write-Host "REMEDIATED: $name set to $verify seconds (0x$("{0:X}" -f $verify))."
    exit 0
} else {
    Write-Error "FAILED: Could not set $name to a compliant value."
    exit 2
}
