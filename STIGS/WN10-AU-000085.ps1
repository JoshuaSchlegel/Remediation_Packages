<#
.SYNOPSIS
    This PowerShell script ensures configuration of audit Object Access - Removable Storage failures.

.NOTES
    Author          : Joshua Schlegel
    LinkedIn        : linkedin.com/in/joshuaschlegel/
    GitHub          : github.com/joshuaschlegel
    Date Created    : 2025-08-24
    Last Modified   : 2025-08-24
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-AU-000085

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-AU-000085.ps1 
#>

# Define the audit subcategory and desired audit setting
$Subcategory = "Removable Storage"
$AuditSetting = "Failure"

# Apply the audit policy setting using AuditPol
$auditResult = AuditPol /set /subcategory:"$Subcategory" /failure:enable

# Check if the command was successful
if ($LASTEXITCODE -eq 0) {
    Write-Host "Policy 'Audit Removable Storage' has been configured to log failures successfully."
} else {
    Write-Host "Failed to configure 'Audit Removable Storage' policy. Error code: $LASTEXITCODE"
}
gpupdate /force
