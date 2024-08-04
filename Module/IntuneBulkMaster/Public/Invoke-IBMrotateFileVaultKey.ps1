function Invoke-IBMrotateFileVaultKey {

    <#
    .SYNOPSIS
        Rotates the FileVault encryption key for macOS devices managed by Intune.

    .DESCRIPTION
        The `Invoke-IBMrotateFileVaultKey` function triggers a rotation of the FileVault encryption key on macOS devices managed by Intune. 
        You can specify devices individually using `DeviceId`, `GroupName`, `DeviceName`, or `OS`. 
        Additionally, you can choose to rotate the FileVault key for all devices or select specific devices/groups interactively.

    .NOTES
        Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
        Version: 1.1
        Date: 2024-08-03

        Changelog:
        - 2024-08-01: 1.0 Initial version
        - 2024-08-03: 1.1 Added filtering for only macOS Devices
        
    #>
    
    param (
        [parameter(Mandatory = $false, HelpMessage = "Specify the ID of the individual device to rotate the FileVault key.")]
        [string]$DeviceId,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group that contains the devices for which to rotate the FileVault key.")]
        [string]$GroupName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the individual device to rotate the FileVault key.")]
        [string]$DeviceName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the operating system of the devices to rotate the FileVault key. For example, 'macOS'.")]
        [string]$OS,
        
        [parameter(Mandatory = $false, HelpMessage = "Rotate the FileVault key for all macOS devices managed by Intune.")]
        [switch]$AllDevices,

        [parameter(Mandatory = $false, HelpMessage = "Interactively select specific devices to rotate the FileVault key.")]
        [switch]$SelectDevices,

        [parameter(Mandatory = $false, HelpMessage = "Interactively select a specific group of devices to rotate the FileVault key.")]
        [switch]$SelectGroup
    )

    # Definition of supported OS for this remote action
    $SupportetOS = @("macOS")

    # Get device IDs based on provided criteria
    if($AllDevices){
        $CollectionDevicesInfo = Get-IBMIntuneDeviceInfos -OS "macOS" -AllDeviceInfo # cause its only supported for them ;)  
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

    # rotate FileVault Key for each device
    $counter = 0
    foreach ($DeviceInfo in $CollectionDevicesInfo) {
        $counter++
        Write-Progress -Id 0 -Activity "Rotate FileVault Key" -Status "Processing $($counter) of $($CollectionDevicesInfo.count)" -CurrentOperation $computer -PercentComplete (($counter/$CollectionDevicesInfo.Count) * 100)

        if($DeviceInfo.operatingSystem -notin $SupportetOS){
            Write-Warning "FileVault Key rotation is only supported for ""$SupportetOS"" devices. Skipping device ID: $($DeviceInfo.id)"
            continue
        }
        $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices/$($DeviceInfo.id)/rotateFileVaultKey"
        
        try {
            $response = Invoke-MgGraphRequest -Method POST -Uri $uri
            Write-Verbose "FileVault Key rotation triggered for device ID: $($DeviceInfo.id). $Response"
        } catch {
            Write-Error "An error occurred while rotating FileVault Key for device ID: $($DeviceInfo.id). Error: $_"
        }
    }
}

