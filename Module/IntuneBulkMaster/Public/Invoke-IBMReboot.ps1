function Invoke-IBMReboot {

    <#
    .SYNOPSIS
        Triggers a reboot for Intune managed devices based on specified criteria.

    .DESCRIPTION
        The Invoke-IBMReboot function allows you to trigger a reboot for Intune managed devices. 
        You can specify individual devices by DeviceId, GroupName, DeviceName, or OS. 
        Additionally, you can choose to reboot all devices or select devices/groups interactively.

    .NOTES
        Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
        Version: 1.0
        Date: 2024-08-01

        Changelog:
        - 2024-08-01: 1.0 Initial version
        
    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Specify the ID of the individual device to reboot.")]
        [string]$DeviceId,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group to which the devices belong.")]
        [string]$GroupName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the individual device to reboot.")]
        [string]$DeviceName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the operating system of the devices to reboot. For example, 'Windows' or 'iOS'.")]
        [string]$OS,
        
        [parameter(Mandatory = $false, HelpMessage = "Reboot all devices managed by Intune.")]
        [switch]$AllDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select specific devices interactively to reboot.")]
        [switch]$SelectDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select a specific group of devices interactively to reboot.")]
        [switch]$SelectGroup
    )

    # Get device IDs based on provided criteria
    if($AllDevices){
        $deviceIds = Get-IBMIntuneDeviceInfos -AllDevices 
    }elseif($SelectDevices){
        $deviceIds = Get-IBMIntuneDeviceInfos -SelectDevices
    }elseif($SelectGroup){
        $deviceIds = Get-IBMIntuneDeviceInfos -SelectGroup
    }else{
        $deviceIds = Get-IBMIntuneDeviceInfos -DeviceId $DeviceId -GroupName $GroupName -DeviceName $DeviceName -OS $OS 
    }

    if (-not $deviceIds) {
        Write-Output "No devices found based on the provided criteria."
        return
    }

    # Reboot each device
    $counter = 0
    foreach ($deviceId in $deviceIds) {
        $counter++
        Write-Progress -Id 0 -Activity "Trigger Reboot for devices" -Status "Processing $($counter) of $($deviceIds.count)" -CurrentOperation $computer -PercentComplete (($counter/$deviceIds.Count) * 100)

        $uri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/$deviceId/rebootNow"
        
        try {
            $response = Invoke-MgGraphRequest -Method POST -Uri $uri
            Write-Verbose "Reboot triggered for device ID: $deviceId. $Response"
        } catch {
            Write-Output "An error occurred while triggering a reboot for device ID: $deviceId. Error: $_"
        }
    }
}

