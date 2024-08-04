function Invoke-IBMremoteLock {

    <#
    .SYNOPSIS
        Triggers a remote lock on Intune managed devices.

    .DESCRIPTION
        The `Invoke-IBMremoteLock` function allows you to remotely lock Intune managed devices. 
        You can specify devices individually using `DeviceId`, `GroupName`, `DeviceName`, or `OS`. 
        Additionally, you can choose to lock all devices or select specific devices/groups interactively.

    .NOTES
        Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
        Version: 1.1
        Date: 2024-08-03

        Changelog:
        - 2024-08-01: 1.0 Initial version
        - 2024-08-03: 1.1 Added filtering for only supported OS types
        
    #>
    
    param (
        [parameter(Mandatory = $false, HelpMessage = "Specify the ID of the individual device to lock.")]
        [string]$DeviceId,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group containing devices to lock.")]
        [string]$GroupName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the individual device to lock.")]
        [string]$DeviceName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the operating system of the devices to lock. For example, 'Windows' or 'iOS'.")]
        [string]$OS,
        
        [parameter(Mandatory = $false, HelpMessage = "Lock all devices managed by Intune.")]
        [switch]$AllDevices,

        [parameter(Mandatory = $false, HelpMessage = "Interactively select specific devices to lock.")]
        [switch]$SelectDevices,

        [parameter(Mandatory = $false, HelpMessage = "Interactively select a specific group of devices to lock.")]
        [switch]$SelectGroup
    )

    # Definition of supported OS for this remote action
    $SupportetOS = @("macOS", "Android", "iOS", "iPadOS")

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

    # Remote Lock for each device
    $counter = 0
    foreach ($DeviceInfo in $CollectionDevicesInfo) {
        $counter++
        Write-Progress -Id 0 -Activity "Remote Lock" -Status "Processing $($counter) of $($CollectionDevicesInfo.count)" -CurrentOperation $computer -PercentComplete (($counter/$CollectionDevicesInfo.Count) * 100)

        if($DeviceInfo.operatingSystem -notin $SupportetOS){
            Write-Warning "Remote Lock is only supported for ""$SupportetOS"" devices. Skipping device ID: $($DeviceInfo.id)"
            continue
        }
        $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices/$($DeviceInfo.id)/remoteLock"
        
        try {
            $response = Invoke-MgGraphRequest -Method POST -Uri $uri
            Write-Verbose "Remote Lock triggered for device ID: $($DeviceInfo.id). $Response"
        } catch {
            Write-Error "An error occurred while Remote Lock device ID: $($DeviceInfo.id). Error: $_"
        }
    }
}
