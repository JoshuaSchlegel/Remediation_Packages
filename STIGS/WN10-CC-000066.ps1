<#
.SYNOPSIS
    This PowerShell script ensures that the command line data includes in process creation events.

.NOTES
    Author          : Joshua Schlegel
    LinkedIn        : linkedin.com/in/joshuaschlegel/
    GitHub          : github.com/joshuaschlegel
    Date Created    : 2025-08-24
    Last Modified   : 2025-08-24
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000066

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-CC-000066.ps1 
#>

# Define registry path and value
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit"
$valueName = "ProcessCreationIncludeCmdLine_Enabled"
$valueData = 1

# Ensure the registry path exists
if (-not (Test-Path -Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force
}

# Set the registry value
Write-Output "Configuring 'Include command line in process creation events' policy..."
Set-ItemProperty -Path $regPath -Name $valueName -Value $valueData -Force

# Verify the configuration
$currentValue = (Get-ItemProperty -Path $regPath -Name $valueName).$valueName
if ($currentValue -eq $valueData) {
    Write-Output "Configuration successful: 'Include command line in process creation events' is enabled."
} else {
    Write-Warning "Configuration failed. Please check the registry manually."
}
```

---

## **Execution Instructions**

### **Step 1: Save the Script**
1. Save the script as `EnableCmdLinePolicy.ps1`.

### **Step 2: Run PowerShell as Administrator**
1. Open PowerShell with elevated privileges.

### **Step 3: Execute the Script**
1. Run the following command:
   ```powershell
   .\EnableCmdLinePolicy.ps1
   ```

---

## **Verification**

### **Manual Verification**
After running the script, confirm the value in the registry editor:
1. Open `regedit`.
2. Navigate to:
   ```
   HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit
   ```
3. Verify that `ProcessCreationIncludeCmdLine_Enabled` is set to `1`.

### **Event Validation**
1. Enable process creation auditing if not already set:
   ```powershell
   auditpol /set /subcategory:"Process Creation" /success:enable
   ```
2. Open **Event Viewer**.
   - Navigate to **Windows Logs > Security**.
   - Look for Event ID **4688**.
   - Verify that command-line details appear in the event.

---

## **Troubleshooting**

### **1. Registry Path Missing**
If the registry path does not exist, the script will create it. Ensure the script is run as an administrator.

### **2. Group Policy Overrides**
If the setting reverts, check for Group Policy Objects (GPOs) overriding the local configuration:
1. Generate a Group Policy Result Report:
   ```powershell
   gpresult /h "$env:TEMP\gpresult.html"
   start "$env:TEMP\gpresult.html"
   ```
2. Review the report for GPOs affecting the policy.

### **3. Manually Configure via Group Policy Editor**
1. Open `gpedit.msc`.
2. Navigate to:
   ```
   Computer Configuration > Administrative Templates > System > Audit Process Creation > Include command line in process creation events
   ```
3. Set the policy to **Enabled**.

---

## **Resources**
- [Microsoft Documentation: Auditpol Command](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/auditpol)
- [STIG Viewer for Compliance Validation](https://public.cyber.mil/stigs/)
