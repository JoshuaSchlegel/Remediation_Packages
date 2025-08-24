<#
.SYNOPSIS
    This PowerShell script ensures the configuration to audit Account Management - User Account Management failures.

.NOTES
    Author          : Joshua Schlegel
    LinkedIn        : linkedin.com/in/joshuaschlegel/
    GitHub          : github.com/joshuaschlegel
    Date Created    : 2025-08-24
    Last Modified   : 2025-08-24
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-AU-000035

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-AU-000035.ps1 
#>

# Ensure the script is running with administrator privileges
if (-not (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Audit")) {
    Write-Host "Creating the registry key for Audit policy..."
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Audit" -Force
}

# Define registry path and values for "Audit Account Management" policy
$auditPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Audit"
$auditAccountManagement = "AuditAccountManagement"

# Enable audit for Account Management
Write-Host "Configuring audit for Account Management failures..."
Set-ItemProperty -Path $auditPath -Name $auditAccountManagement -Value 0x3  # 0x3 corresponds to 'Success and Failure' auditing

# Enable specific "Audit User Account Management failures"
Write-Host "Setting audit policy for 'User Account Management' failures..."
auditpol /set /subcategory:"Logon/Logoff" /failure:enable  # This enables failures auditing for logon events

auditpol /set /subcategory:"Account Lockout" /failure:enable  # This enables failures for account lockout
auditpol /set /subcategory:"Special Logon" /failure:enable  # This enables failures for special logons (e.g. local/remote logons)

# Confirm changes to the user
Write-Host "Audit policy for User Account Management failures has been configured successfully."
