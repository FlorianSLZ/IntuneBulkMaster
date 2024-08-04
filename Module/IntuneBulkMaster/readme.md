<p align="center">
    <a href="https://scloud.work" alt="Florian Salzmann | scloud"></a>
            <img src="https://scloud.work/wp-content/uploads/IntuneBulkMaster-Icon.png" width="75" height="75" /></a>
</p>
<p align="center">
    <a href="https://www.linkedin.com/in/fsalzmann/">
        <img alt="Made by" src="https://img.shields.io/static/v1?label=made%20by&message=Florian%20Salzmann&color=04D361">
    </a>
    <a href="https://x.com/FlorianSLZ" alt="X / Twitter">
    	<img src="https://img.shields.io/twitter/follow/FlorianSLZ.svg?style=social"/>
    </a>
</p>
<p align="center">
    <a href="https://www.powershellgallery.com/packages/IntuneBulkMaster/" alt="PowerShell Gallery Version">
        <img src="https://img.shields.io/powershellgallery/v/IntuneBulkMaster.svg" />
    </a>
    <a href="https://www.powershellgallery.com/packages/IntuneBulkMaster/" alt="PS Gallery Downloads">
        <img src="https://img.shields.io/powershellgallery/dt/IntuneBulkMaster.svg" />
    </a>
</p>
<p align="center">
    <a href="https://raw.githubusercontent.com/FlorianSLZ/IntuneBulkMaster/master/LICENSE" alt="GitHub License">
        <img src="https://img.shields.io/github/license/FlorianSLZ/IntuneBulkMaster.svg" />
    </a>
    <a href="https://github.com/FlorianSLZ/IntuneBulkMaster/graphs/contributors" alt="GitHub Contributors">
        <img src="https://img.shields.io/github/contributors/FlorianSLZ/IntuneBulkMaster.svg"/>
    </a>
</p>

<p align="center">
    <a href='https://buymeacoffee.com/scloud' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3' border='0' alt='Buy Me a Glass of wine' /></a>
</p>


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
- Get-IBMIntuneDeviceInfos
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
- Remove-IBMAutopilotDevice
- Remove-IBMprimaryUser
- Set-IBMCorporateOwned
- Set-IBMIntuneDeviceName
- Set-IBMPersonalOwned


## Connect-IntuneBulkMaster (Authentification)
Establishes a connection to Microsoft Graph API with required permissions.

```PowerShell
Connect-IntuneBulkMaster
```

### Permissions
- DeviceManagementManagedDevices.ReadWrite.All"
- Device.Read.All
- DeviceManagementManagedDevices.PrivilegedOperations.All


## `Get-IBMIntuneDeviceInfos`
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
Get-IBMIntuneDeviceInfos -GroupName "INTUNE-Devices-Windows-IT"
```

## `Invoke-IBMReboot` and most of the other `Invoke-IBM*`-Functions
Triggers a reboot for Intune-managed devices based on specified criteria.


### Parameters
- Same as `Get-IBMIntuneDeviceInfos`

### Example
```PowerShell
Get-IBMIntuneDeviceInfos -GroupName "INTUNE-Devices-Windows-IT"
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
