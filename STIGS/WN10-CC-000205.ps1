<#
.SYNOPSIS
    This PowerShell script ensures that Windows Telemetry is not configured to Full.

.NOTES
    Author          : Joshua Schlegel
    LinkedIn        : linkedin.com/in/joshuaschlegel/
    GitHub          : github.com/joshuaschlegel
    Date Created    : 2025-08-24
    Last Modified   : 2025-08-24
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000205

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-CC-000205.ps1 
#>

# Ensure the script is running with administrator privileges
if (-not (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection")) {
    Write-Host "Creating registry path for DataCollection..."
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force
}

# Define the registry keys for "Allow Telemetry"
$telemetryRegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
$telemetryRegName = "AllowTelemetry"

# Check Windows version to determine the correct telemetry setting
$windowsVersion = [System.Environment]::OSVersion.Version

# Set default telemetry value based on version
if ($windowsVersion.Major -ge 10 -and $windowsVersion.Build -ge 16299) {
    # Version 1709 or later (Build 16299 or greater)
    Write-Host "Setting telemetry to 'Enhanced' (2 - Enhanced) for Windows 10 version 1709 or later."
    $telemetryValue = 2 # Enhanced telemetry (Windows Analytics supported)
} else {
    # Pre-1709 versions (older builds)
    Write-Host "Setting telemetry to 'Basic' (1 - Basic)."
    $telemetryValue = 1 # Basic telemetry
}

# Set the "Allow Telemetry" registry value
Set-ItemProperty -Path $telemetryRegPath -Name $telemetryRegName -Value $telemetryValue

# V-220833 Compliance: Limit Enhanced data to the minimum required for Windows Analytics
# This can be set by configuring the registry value to control how much telemetry is sent
$limitEnhancedTelemetryKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
$limitEnhancedTelemetryName = "LimitEnhancedTelemetry"
$limitEnhancedTelemetryValue = 1  # Limit telemetry to the minimum required by Windows Analytics

# Ensure registry value exists for limiting Enhanced telemetry
if (-not (Test-Path "$limitEnhancedTelemetryKey\$limitEnhancedTelemetryName")) {
    Write-Host "Creating registry value to limit Enhanced Telemetry to the minimum required by Windows Analytics..."
    New-ItemProperty -Path $limitEnhancedTelemetryKey -Name $limitEnhancedTelemetryName -Value $limitEnhancedTelemetryValue -PropertyType DWord -Force
} else {
    Write-Host "Setting registry value to limit Enhanced Telemetry to the minimum required by Windows Analytics..."
    Set-ItemProperty -Path $limitEnhancedTelemetryKey -Name $limitEnhancedTelemetryName -Value $limitEnhancedTelemetryValue
}

# Confirm changes
Write-Host "Telemetry has been configured successfully."
Write-Host "AllowTelemetry: $(Get-ItemProperty -Path $telemetryRegPath -Name $telemetryRegName).AllowTelemetry"
Write-Host "LimitEnhancedTelemetry: $(Get-ItemProperty -Path $limitEnhancedTelemetryKey -Name $limitEnhancedTelemetryName).LimitEnhancedTelemetry"
# Check the value of AllowTelemetry
Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name AllowTelemetry

# Check the value of LimitEnhancedTelemetry
Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name LimitEnhancedTelemetry
