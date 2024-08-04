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

        Changelog:
        - 2024-08-01: 1.0 Initial version
        - 2024-08-01: 1.1 Added filtering for only macOS Devices

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

    # Definition of supported OS for this remote action
    $SupportetOS = @("macOS")


    # Get device IDs based on provided criteria
    if($AllDevices){
        $CollectionDevicesInfo = Get-IBMIntuneDeviceInfos -AllDeviceInfo   
    }elseif($SelectDevices){
        $CollectionDevicesInfo = Get-IBMIntuneDeviceInfos -SelectDevices -AllDeviceInfo
    }elseif($SelectGroup){
        $CollectionDevicesInfo = Get-IBMIntuneDeviceInfos -SelectGroup -AllDeviceInfo
    }else{
        $CollectionDevicesInfo = Get-IBMIntuneDeviceInfos -DeviceId $DeviceId -GroupName $GroupName -DeviceName $DeviceName -OS $OS -AllDeviceInfo
    }

    if (-not $CollectionDevicesInfo) {
        Write-Warning "No devices found based on the provided criteria."
        return
    }

    # Shut down for each device
    $counter = 0
    foreach ($DeviceInfo in $CollectionDevicesInfo) {
        $counter++
        Write-Progress -Id 0 -Activity "Shut down" -Status "Processing $($counter) of $($CollectionDevicesInfo.count)" -CurrentOperation $computer -PercentComplete (($counter/$CollectionDevicesInfo.Count) * 100)

        if($DeviceInfo.operatingSystem -notin $SupportetOS){
            Write-Warning "Shut down is only supported for ""$SupportetOS"" devices. Skipping device ID: $($DeviceInfo.id)"
            continue
        }
        $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices/$($DeviceInfo.id)/shutDown"
        
        try {
            $response = Invoke-MgGraphRequest -Method POST -Uri $uri
            Write-Verbose "Shut down triggered for device ID: $($DeviceInfo.id). $Response"
        } catch {
            Write-Error "An error occurred while shutting down device ID: $($DeviceInfo.id). Error: $_"
        }
    }
}

