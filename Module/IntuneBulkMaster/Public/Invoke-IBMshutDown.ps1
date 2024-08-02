function Invoke-IBMshutDown {

    <#
    .SYNOPSIS
        Triggers a shutdown for Intune managed devices based on specified criteria.

    .DESCRIPTION
        The `Invoke-IBMshutDown` function allows you to trigger a shutdown for Intune managed devices. 
        You can specify devices individually by using `DeviceId`, `GroupName`, `DeviceName`, or `OS`. 
        Additionally, you can choose to shut down all devices or select specific devices/groups interactively.

    .NOTES
        Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
        Version: 1.0
        Date: 2024-08-01
    #>
    
    param (
        [parameter(Mandatory = $false, HelpMessage = "Specify the ID of the individual device to shut down.")]
        [string]$DeviceId,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group containing devices to shut down.")]
        [string]$GroupName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the individual device to shut down.")]
        [string]$DeviceName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the operating system of the devices to shut down. For example, 'Windows' or 'iOS'.")]
        [string]$OS,
        
        [parameter(Mandatory = $false, HelpMessage = "Shut down all devices managed by Intune.")]
        [switch]$AllDevices,

        [parameter(Mandatory = $false, HelpMessage = "Interactively select specific devices to shut down.")]
        [switch]$SelectDevices,

        [parameter(Mandatory = $false, HelpMessage = "Interactively select a specific group of devices to shut down.")]
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

    # Shut down each device
    $counter = 0
    foreach ($deviceId in $deviceIds) {
        $counter++
        Write-Progress -Id 0 -Activity "Shut down devices" -Status "Processing $($counter) of $($deviceIds.count)" -CurrentOperation $computer -PercentComplete (($counter/$deviceIds.Count) * 100)

        $uri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/$deviceId/shutDown"
        
        try {
            $response = Invoke-MgGraphRequest -Method POST -Uri $uri
            Write-Verbose "Shut down triggered for device ID: $deviceId. $Response"
        } catch {
            Write-Output "An error occurred while shutting down device ID: $deviceId. Error: $_"
        }
    }
}

