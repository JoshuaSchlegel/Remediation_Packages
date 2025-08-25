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
    STIG-ID         : WN10-AU-000575

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-AU-000575.ps1 
#>

# Define log file path
$logFilePath = "$env:TEMP\AuditPolicyConfiguration.log"

# Step 1: Verify current setting
Write-Output "Verifying current audit policy setting for 'MPSSVC Rule-Level Policy Change'..." | Tee-Object -FilePath $logFilePath -Append
$currentSetting = auditpol /get /subcategory:"MPSSVC Rule-Level Policy Change"
$currentSetting | Tee-Object -FilePath $logFilePath -Append

# Check if 'Success' is already enabled
if ($currentSetting -match "Success\s*Disabled") {
    Write-Output "Success auditing is not enabled. Applying the required setting..." | Tee-Object -FilePath $logFilePath -Append

    # Step 2: Configure audit policy
    auditpol /set /subcategory:"MPSSVC Rule-Level Policy Change" /success:enable

    # Step 3: Verify the change
    $updatedSetting = auditpol /get /subcategory:"MPSSVC Rule-Level Policy Change"
    $updatedSetting | Tee-Object -FilePath $logFilePath -Append

    if ($updatedSetting -match "Success\s*Enabled") {
        Write-Output "Audit policy successfully configured for 'MPSSVC Rule-Level Policy Change'." | Tee-Object -FilePath $logFilePath -Append
    } else {
        Write-Warning "Failed to configure audit policy. Please check manually." | Tee-Object -FilePath $logFilePath -Append
    }
} else {
    Write-Output "Success auditing is already enabled for 'MPSSVC Rule-Level Policy Change'." | Tee-Object -FilePath $logFilePath -Append
}

Write-Output "Audit policy configuration process complete. Log saved at: $logFilePath"
```

---

## **Troubleshooting**

### **1. Check Local Policy Settings**
To manually verify settings:
1. Open **Local Group Policy Editor**:
   ```powershell
gpedit.msc
   ```
2. Navigate to:
   ```
   Computer Configuration > Windows Settings > Security Settings > Advanced Audit Policy Configuration > System Audit Policies > Policy Change > MPSSVC Rule-Level Policy Change
   ```
3. Ensure **Success** is selected.

---

### **2. Check for Group Policy Overrides**
If changes are not applied, a Group Policy Object (GPO) might be overriding the local policy.

#### Generate a Group Policy Result Report:
```powershell
gpresult /h "$env:TEMP\gpresult.html"
start "$env:TEMP\gpresult.html"
```
- Check for GPOs affecting the audit policy.

---

### **3. Review Logs**
Check the log file for errors or unexpected outputs:
```powershell
notepad "$env:TEMP\AuditPolicyConfiguration.log"
```

---

## **Execution Steps**
1. Save the script as `ConfigureAuditPolicy.ps1`.
2. Open PowerShell as **Administrator**.
3. Run the script:
   ```powershell
   .\ConfigureAuditPolicy.ps1
   ```

---

## **Resources**
- [Microsoft Documentation: Auditpol Command](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/auditpol)
- [STIG Viewer for Compliance Validation](https://public.cyber.mil/stigs/)
