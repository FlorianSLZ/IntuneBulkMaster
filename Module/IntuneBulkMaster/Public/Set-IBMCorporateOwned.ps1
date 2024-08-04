function Set-IBMCorporateOwned {

    <#
    .SYNOPSIS
        Sets Intune managed devices to corporate-owned based on specified criteria.

    .DESCRIPTION
        The Set-IBMCorporateOwned function allows you to set devices to corporate-owned in Intune.
        You can specify individual devices by DeviceId, GroupName, DeviceName, or OS.
        Additionally, you can choose to set all devices or select devices/groups interactively.

    .NOTES
        Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
        Version: 1.0
        Date: 2024-08-03

        Changelog:
        - 2024-08-03: 1.0 Initial version
        
    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Specify the ID of the individual device to set as corporate-owned.")]
        [string]$DeviceId,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group to which the devices belong.")]
        [string]$GroupName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the individual device to set as corporate-owned.")]
        [string]$DeviceName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the operating system of the devices to set as corporate-owned. For example, 'Windows' or 'iOS'.")]
        [string]$OS,
        
        [parameter(Mandatory = $false, HelpMessage = "Set all devices managed by Intune as corporate-owned.")]
        [switch]$AllDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select specific devices interactively to set as corporate-owned.")]
        [switch]$SelectDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select a specific group of devices interactively to set as corporate-owned.")]
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
        Write-Warning "No devices found based on the provided criteria."
        return
    }

    # Set each device to corporate-owned
    $counter = 0
    foreach ($deviceId in $deviceIds) {
        $counter++
        Write-Progress -Id 0 -Activity "Setting devices to corporate-owned" -Status "Processing $($counter) of $($deviceIds.count)" -CurrentOperation $deviceId -PercentComplete (($counter/$deviceIds.Count) * 100)

        $uri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/$deviceId"

        $body = @{
            managedDeviceOwnerType = "company"
        }

        $jsonBody = $body | ConvertTo-Json

        try {
            $response = Invoke-MgGraphRequest -Method PATCH -Uri $uri -Body $jsonBody -ContentType "application/json"
            Write-Verbose "Device ID: $deviceId set to corporate-owned. $response"
        } catch {
            Write-Output "An error occurred while setting device ID: $deviceId to corporate-owned. Error: $_"
        }
    }
}
