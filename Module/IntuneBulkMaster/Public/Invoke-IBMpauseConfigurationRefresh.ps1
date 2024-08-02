function Invoke-IBMpauseConfigurationRefresh {

    <#
    .SYNOPSIS
        Triggers a pause of the configuration refresh for Intune managed devices based on specified criteria.

    .DESCRIPTION
        The `Invoke-IBMpauseConfigurationRefresh` function pauses the configuration refresh for Intune managed devices. 
        You can specify individual devices by `DeviceId`, `GroupName`, `DeviceName`, or `OS`. 
        Additionally, you can choose to pause all devices or select specific devices/groups interactively.

    .NOTES
        Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
        Version: 1.0
        Date: 2024-08-01
    #>
    
    param (
        [parameter(Mandatory = $false, HelpMessage = "Specify the ID of the individual device to pause configuration refresh.")]
        [string]$DeviceId,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group containing devices to pause configuration refresh.")]
        [string]$GroupName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the individual device to pause configuration refresh.")]
        [string]$DeviceName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the operating system of the devices to pause configuration refresh. For example, 'Windows' or 'iOS'.")]
        [string]$OS,
        
        [parameter(Mandatory = $false, HelpMessage = "Pause configuration refresh for all devices managed by Intune.")]
        [switch]$AllDevices,

        [parameter(Mandatory = $false, HelpMessage = "Interactively select specific devices to pause configuration refresh.")]
        [switch]$SelectDevices,

        [parameter(Mandatory = $false, HelpMessage = "Interactively select a specific group of devices to pause configuration refresh.")]
        [switch]$SelectGroup
    )

    # Get device IDs based on provided criteria
    if($AllDevices){
        $deviceIds = Get-IntuneDeviceIDs -AllDevices 
    }elseif($SelectDevices){
        $deviceIds = Get-IntuneDeviceIDs -SelectDevices
    }elseif($SelectGroup){
        $deviceIds = Get-IntuneDeviceIDs -SelectGroup
    }else{
        $deviceIds = Get-IntuneDeviceIDs -DeviceId $DeviceId -GroupName $GroupName -DeviceName $DeviceName -OS $OS 
    }

    if (-not $deviceIds) {
        Write-Warning "No devices found based on the provided criteria."
        return
    }

    # pause config refresh for each device
    $counter = 0
    foreach ($deviceId in $deviceIds) {
        $counter++
        Write-Progress -Id 0 -Activity "Pause config refresh for the devices" -Status "Processing $($counter) of $($deviceIds.count)" -CurrentOperation $computer -PercentComplete (($counter/$deviceIds.Count) * 100)

        $uri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/$deviceId/pauseConfigurationRefresh"
        
        try {
            $response = Invoke-MgGraphRequest -Method POST -Uri $uri
            Write-Verbose "Pause config refresh triggered for device ID: $deviceId. $Response"
        } catch {
            Write-Output "An error occurred while pausing config refresh for device ID: $deviceId. Error: $_"
        }
    }
}

