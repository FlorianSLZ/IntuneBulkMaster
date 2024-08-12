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
        Version: 1.3
        Date: 2024-08-12

        Changelog:
        - 2024-08-01: 1.0 Initial version
        - 2024-08-03: 1.1 Added filtering for only macOS Devices
        - 2024-08-06: 1.2
            - Added batching / batch requests for large device collections and speed improvements (seperate function: Invoke-IBMGrapAPIBatching)
            - Aligment of all Action functions to the same structure
        - 2024-08-12: 1.3
            - Optimized handling of unsupported OS
        
    #>
    
    param (
        [parameter(Mandatory = $false, HelpMessage = "Specify the ID of the individual device to rotate the FileVault key.")]
        [string]$DeviceId,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group that contains the devices for which to rotate the FileVault key.")]
        [string]$GroupName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the individual device to rotate the FileVault key.")]
        [string]$DeviceName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the operating system of the devices to rotate the FileVault key. For example, 'macOS'.")]
        [string[]]$OS,
        
        [parameter(Mandatory = $false, HelpMessage = "Rotate the FileVault key for all macOS devices managed by Intune.")]
        [switch]$AllDevices,

        [parameter(Mandatory = $false, HelpMessage = "Interactively select specific devices to rotate the FileVault key.")]
        [switch]$SelectDevices,

        [parameter(Mandatory = $false, HelpMessage = "Interactively select a specific group of devices to rotate the FileVault key.")]
        [switch]$SelectGroup
    )

    # Definition of supported OS for this remote action
    $SupportetOS = @("macOS")

    if($OS -and $SupportetOS -notcontains $OS){
        Write-Warning "The specified operating system ""$OS"" is not supported for this action. Supported OS ""$SupportetOS""."
        return
    }
        
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

    # collection for unsupported OS
    $UnsupportedDevices = $CollectionDevicesInfo | Where-Object { $SupportetOS -notcontains $_.operatingSystem }
    if($UnsupportedDevices){
        Write-Warning "Unsuported devices for this action wont be processed: $($UnsupportedDevices.count)"
        Write-Host "Use -Verbose to show details."
        Write-Verbose $UnsupportedDevices.id
    }
    
    # filter out supported OS
    $CollectionDevicesInfo = $CollectionDevicesInfo | Where-Object { $SupportetOS -contains $_.operatingSystem }

    if (-not $CollectionDevicesInfo) {
        Write-Warning "No devices found based on the provided criteria."
        return
    }

    # Rotate FileVault Key each device
    $batchingParams = @{
        "Objects2Process"       = $CollectionDevicesInfo.id
        "ActionURI"             = "deviceManagement/managedDevices/{0}/rotateFileVaultKey/"
        "Method"                = "POST"
        "GraphVersion"          = "beta"
		"BodySingle"            = @{}
        "ActionTitle"           = "Rotate FileVault Key"
    } 
    Invoke-IBMGrapAPIBatching @batchingParams

}
