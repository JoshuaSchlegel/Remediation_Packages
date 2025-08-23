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
    STIG-ID         : WN10-SO-000005

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-SO-000005.ps1 
#>

# Requires: Run as Administrator
# Purpose: Ensure the built-in Administrator (RID 500) is DISABLED.

# --- Helper: admin check ---
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Error "Please run this script in an elevated PowerShell session."
    exit 2
}

# --- Locate the built-in Administrator by SID (…-500), works even if renamed ---
function Get-BuiltInAdministrator {
    try {
        if (Get-Command Get-LocalUser -ErrorAction SilentlyContinue) {
            return Get-LocalUser | Where-Object { $_.SID.Value -match '-500$' }
        } else {
            # Fallback for environments without LocalAccounts module
            return Get-WmiObject Win32_UserAccount -Filter "LocalAccount=true" | Where-Object { $_.SID -match '-500$' }
        }
    } catch {
        Write-Error "Failed to query local users: $($_.Exception.Message)"
        return $null
    }
}

$adminAcct = Get-BuiltInAdministrator
if (-not $adminAcct) {
    Write-Error "Could not find the built-in Administrator (RID 500)."
    exit 2
}

# Normalize object shape (Enabled property name differs between cmdlets/WMI)
if ($adminAcct.PSObject.Properties['Enabled']) {
    $isEnabled = [bool]$adminAcct.Enabled
    $adminName = $adminAcct.Name
} else {
    $isEnabled = -not [bool]$adminAcct.Disabled
    $adminName = $adminAcct.Name
}

Write-Host "Built-in Administrator account detected: '$adminName' (RID 500). Enabled: $isEnabled"

# --- Audit result (before) ---
if (-not $isEnabled) {
    Write-Host "COMPLIANT: 'Accounts: Administrator account status' is Disabled."
    exit 0
}

Write-Host "NON-COMPLIANT: Administrator account is enabled. Attempting to disable…"

# --- Remediation ---
$remediationSucceeded = $false
try {
    if (Get-Command Disable-LocalUser -ErrorAction SilentlyContinue) {
        # Use LocalAccounts module if available
        $adminObj = Get-LocalUser | Where-Object { $_.SID.Value -match '-500$' }
        Disable-LocalUser -InputObject $adminObj -ErrorAction Stop
        $remediationSucceeded = $true
    } else {
        # Fallback using 'net user' (works across PS versions)
        $escaped = $adminName -replace '"','\"'
        $p = Start-Process -FilePath cmd.exe -ArgumentList "/c","net user `"$escaped`" /active:no" -Wait -PassThru -WindowStyle Hidden
        if ($p.ExitCode -eq 0) { $remediationSucceeded = $true }
    }
} catch {
    Write-Error "Remediation error: $($_.Exception.Message)"
    $remediationSucceeded = $false
}

# --- Re-verify ---
$adminAcct = Get-BuiltInAdministrator
if ($adminAcct.PSObject.Properties['Enabled']) {
    $isEnabled = [bool]$adminAcct.Enabled
} else {
    $isEnabled = -not [bool]$adminAcct.Disabled
}

if ($remediationSucceeded -and -not $isEnabled) {
    Write-Host "REMEDIATED: Built-in Administrator is now disabled. Policy is COMPLIANT."
    exit 0
} elseif (-not $remediationSucceeded) {
    Write-Error "FAILED: Could not disable the built-in Administrator account."
    exit 2
} else {
    Write-Error "FAILED: Attempted remediation, but the account remains enabled."
    exit 2
}
