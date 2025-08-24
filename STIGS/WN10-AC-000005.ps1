<#
.SYNOPSIS
    This PowerShell script ensures configuration of Account Lockout Policy, handle logs, and provide help documentation.

.NOTES
    Author          : Joshua Schlegel
    LinkedIn        : linkedin.com/in/joshuaschlegel/
    GitHub          : github.com/joshuaschlegel
    Date Created    : 2025-08-24
    Last Modified   : 2025-08-24
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-AC-000005

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-AC-000005.ps1 
#>

# Define global variables
$logFilePath = "$env:TEMP\AccountLockoutConfiguration.log"
$tempTemplatePath = "$env:TEMP\SecurityTemplate.inf"
$accountLockoutDuration = 15  # Set to 0 if administrator unlock is required

function Show-Help {
    <#
    .SYNOPSIS
    Displays the help documentation for this script.

    .DESCRIPTION
    Provides information about configuring policies, handling logs, and the usage of this script.
    #>
    @"
Help Hub - Unified PowerShell Script

Features:
1. Configure Account Lockout Duration Policy
2. Manage logs (view, copy, delete)
3. Display this help message

Usage:
1. To configure the policy, run this script as Administrator.
2. Follow the prompts to handle logs interactively.

License: MIT
"@
}

function Configure-AccountLockoutPolicy {
    Write-Output "Starting configuration of Account Lockout Duration policy..." | Tee-Object -FilePath $logFilePath

    # Create a temporary security template
    Write-Output "Creating temporary security template..." | Tee-Object -FilePath $logFilePath -Append
    @"
[System Access]
LockoutDuration = $accountLockoutDuration
"@ | Out-File -FilePath $tempTemplatePath -Encoding ASCII

    # Apply the template using secedit
    try {
        Write-Output "Applying the security template..." | Tee-Object -FilePath $logFilePath -Append
        secedit /configure /db "$env:TEMP\SecurityDatabase.sdb" /cfg $tempTemplatePath /areas SECURITYPOLICY | Out-File -FilePath $logFilePath -Append
        Write-Output "Account Lockout Duration configured to $accountLockoutDuration minute(s)." | Tee-Object -FilePath $logFilePath -Append
    } catch {
        Write-Error "Failed to apply the security template. Error: $_" | Tee-Object -FilePath $logFilePath -Append
        return
    } finally {
        # Clean up temporary files
        Remove-Item -Path $tempTemplatePath -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:TEMP\SecurityDatabase.sdb" -Force -ErrorAction SilentlyContinue
    }

    # Update group policies
    Write-Output "Updating policies..." | Tee-Object -FilePath $logFilePath -Append
    gpupdate /force | Out-File -FilePath $logFilePath -Append

    # Verify the configuration
    Write-Output "Verifying the configuration..." | Tee-Object -FilePath $logFilePath -Append
    try {
        $tempExportPath = "$env:TEMP\SecurityExport.inf"
        secedit /export /cfg $tempExportPath /areas SECURITYPOLICY | Out-File -FilePath $logFilePath -Append
        $exportedConfig = Get-Content -Path $tempExportPath
        if ($exportedConfig -match "LockoutDuration\s*=\s*$accountLockoutDuration") {
            Write-Output "Verification successful: Lockout duration is set to $accountLockoutDuration minute(s)." | Tee-Object -FilePath $logFilePath -Append
        } else {
            Write-Warning "Verification failed: Lockout duration is not configured as expected." | Tee-Object -FilePath $logFilePath -Append
        }
    } catch {
        Write-Error "Failed to verify the configuration. Error: $_" | Tee-Object -FilePath $logFilePath -Append
    } finally {
        Remove-Item -Path $tempExportPath -Force -ErrorAction SilentlyContinue
    }
}

function Handle-Logs {
    Write-Output "Log File Management" | Tee-Object -FilePath $logFilePath -Append

    # Open log in Notepad
    Write-Output "Opening log file in Notepad..." | Tee-Object -FilePath $logFilePath -Append
    Start-Process -FilePath "notepad.exe" -ArgumentList $logFilePath

    # Display log content in PowerShell
    Write-Output "Displaying log file content:" | Tee-Object -FilePath $logFilePath -Append
    Get-Content -Path $logFilePath | Tee-Object -FilePath $logFilePath -Append

    # Copy log to another location
    $destinationPath = Read-Host "Enter the destination folder to save the log file (e.g., C:\Logs)"
    if (-not (Test-Path $destinationPath)) {
        Write-Output "Destination folder does not exist. Creating it..." | Tee-Object -FilePath $logFilePath -Append
        New-Item -ItemType Directory -Path $destinationPath
    }
    $copiedFilePath = Join-Path -Path $destinationPath -ChildPath "AccountLockoutConfiguration.log"
    Copy-Item -Path $logFilePath -Destination $copiedFilePath
    Write-Output "Log file copied to: $copiedFilePath" | Tee-Object -FilePath $logFilePath -Append

    # Optionally delete the log file
    $deleteChoice = Read-Host "Do you want to delete the original log file? (yes/no)"
    if ($deleteChoice -eq "yes") {
        Remove-Item -Path $logFilePath -Force
        Write-Output "Log file deleted from: $logFilePath"
    } else {
        Write-Output "Log file retained at: $logFilePath"
    }
}

# Main Menu
Write-Output "Welcome to the Unified PowerShell Help Hub"
Write-Output "Select an option:"
Write-Output "1. Configure Account Lockout Policy"
Write-Output "2. Handle Logs"
Write-Output "3. Show Help"
Write-Output "4. Exit"

$choice = Read-Host "Enter your choice (1-4)"
switch ($choice) {
    1 { Configure-AccountLockoutPolicy }
    2 { Handle-Logs }
    3 { Show-Help | Out-Host }
    4 { Write-Output "Exiting script. Goodbye!" }
    default { Write-Output "Invalid choice. Please try again." }
}
