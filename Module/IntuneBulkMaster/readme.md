<div> 
<a href="https://x.com/FlorianSLZ/" target="_blank"><img src="https://img.shields.io/twitter/follow/FlorianSLZ" target="_blank"></a> 
<a href="https://www.linkedin.com/in/fsalzmann/" target="_blank"><img src="https://img.shields.io/badge/-LinkedIn-%230077B5?style=for-the-badge&logo=linkedin&logoColor=white" target="_blank"></a> 
<a href="https://scloud.work/en/about" target="_blank"><img src="https://img.shields.io/badge/website-000000?style=for-the-badge&logo=About.me&logoColor=white" target="_blank"></a> 
</div>


# IntuneBulkMaster Module

![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/IntuneBulkMaster)


The `IntuneBulkMaster` PowerShell module provides a set of functions for managing and interacting with Microsoft Intune. It is designed to perform bulk operations on Intune-managed devices, such as rebooting, collecting diagnostics, and rotating keys. This module facilitates efficient management of devices by allowing administrators to perform tasks across multiple devices or groups with ease.

## Installing the module from PSGallery

The IntuneWin32App module is published to the [PowerShell Gallery](https://www.powershellgallery.com/packages/IntuneBulkMaster). 
Install it on your system by running the following in an elevated PowerShell console:
```PowerShell
Install-Module -Name IntuneBulkMaster
```

## Import the module for testing

As an alternative to installing, you chan download this Repository and import it in a PowerShell Session. 
*The path may be different in your case*
```PowerShell
Import-Module -Name "C:\GitHub\IntuneBulkMaster\Module\IntuneBulkMaster" -Verbose -Force
```

## Module dependencies

IntuneBulkMaster module requires the following modules, which will be automatically installed as dependencies:
- Microsoft.Graph.Authentication

# Functions / Examples

Here are all functions and some examples to start with:

- Connect-IntuneBulkMaster
- Get-IntuneDeviceIDs
- Invoke-IBMcollectDiagnostics
- Invoke-IBMPagingRequest
- Invoke-IBMpauseConfigurationRefresh
- Invoke-IBMReboot
- Invoke-IBMRemediations
- Invoke-IBMremoteLock
- Invoke-IBMrotateBitLockerKeys
- Invoke-IBMrotateFileVaultKey
- Invoke-IBMrotateLAPS
- Invoke-IBMshutDown
- Invoke-IBMSync


## Connect-IntuneBulkMaster (Authentification)
Establishes a connection to Microsoft Graph API with required permissions.

```PowerShell
Connect-IntuneBulkMaster
```

### Permissions
- DeviceManagementManagedDevices.ReadWrite.All"
- Device.Read.All
- DeviceManagementManagedDevices.PrivilegedOperations.All


## `Get-IntuneDeviceIDs`
Retrieves device IDs from Intune based on specified criteria. 

You can call this function amanully or with the same parameters for each bulk action. 

### Parameters
-DeviceId (string): The ID of the device.
-GroupName (string): The name of the group containing the devices.
-DeviceName (string): The name of the device.
-OS (string): The operating system of the devices.
-AllDevices (switch): Get all devices.
-SelectDevices (switch): Select specific devices interactively.
-SelectGroup (switch): Select a specific group interactively.

### Example
```PowerShell
Get-IntuneDeviceIDs -GroupName "INTUNE-Devices-Windows-IT"
```

## `Invoke-IBMReboot` and most of the other `Invoke-IBM*`-Functions
Triggers a reboot for Intune-managed devices based on specified criteria.


### Parameters
- Same as `Get-IntuneDeviceIDs`

### Example
```PowerShell
Get-IntuneDeviceIDs -GroupName "INTUNE-Devices-Windows-IT"
```

## `Invoke-IBMRemediations`

Triggers proactive remediation scripts for Intune-managed devices based on specified criteria.

### Description
The `Invoke-IBMRemediations` function allows you to trigger proactive remediation scripts for Intune-managed devices in bulk. 

This function first retrieves a list of available remediations and allows you to select one to apply. It then initiates the remediation process on the specified devices.

*Credits: Kudos to Andrew Taylor for his initial function, which he presented during the #MEMSummit 2023 in Paris. [Read more](https://andrewstaylor.com/2023/09/06/remediations-on-demand-in-bulk/)*

### Parameters
- `-DeviceId` (string): Specify the ID of the individual device to remediate.
- `-GroupName` (string): Specify the name of the group to which the devices belong.
- `-DeviceName` (string): Specify the name of the individual device to remediate.
- `-OS` (string): Specify the operating system of the devices to remediate (e.g., 'Windows', 'iOS').
- `-AllDevices` (switch): Trigger remediation for all devices managed by Intune.
- `-SelectDevices` (switch): Select specific devices interactively to remediate.
- `-SelectGroup` (switch): Select a specific group of devices interactively to remediate.

### Example
```powershell
Invoke-IBMRemediations -OS "Windows"
```

### Workflow
- *Retrieve Remediations:* The function fetches a list of all available remediation scripts and presents them for selection.
- *Select Devices:* Based on the provided criteria, the function determines which devices to apply the remediation to.
- *Trigger Remediation:* The selected remediation script is applied to each device.
