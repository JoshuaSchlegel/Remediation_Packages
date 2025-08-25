<#
.SYNOPSIS
    This PowerShell script ensures configuration of Windows 10 to audit MPSSVC Rule-Level Policy Change Successes.

.NOTES
    Author          : Joshua Schlegel
    LinkedIn        : linkedin.com/in/joshuaschlegel/
    GitHub          : github.com/joshuaschlegel
    Date Created    : 2025-08-24
    Last Modified   : 2025-08-24
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000090

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-CC-000090.ps1 
#>

# Define the registry path and value for the policy
$RegPath = "HKLM:\Software\Policies\Microsoft\Windows\System"
$RegName1 = "EnableRegistryPolicyProcessing"
$RegName2 = "RegistryPolicyProcessing"
$RegValue1 = 1  # 1 means Enabled
$RegValue2 = 1  # 1 means 'Process even if the Group Policy objects have not changed'

# Check if the registry path exists, and create it if it doesn't
if (-not (Test-Path -Path $RegPath)) {
    New-Item -Path $RegPath -Force
}

# Set the registry value to enable the policy
Set-ItemProperty -Path $RegPath -Name $RegName1 -Value $RegValue1
Set-ItemProperty -Path $RegPath -Name $RegName2 -Value $RegValue2

# Output a message indicating the operation is complete
Write-Host "Policy 'Configure registry policy processing' has been set to 'Enabled' with the option 'Process even if the Group Policy objects have not changed'."
 
