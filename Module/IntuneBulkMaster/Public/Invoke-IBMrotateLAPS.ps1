function Invoke-IBMrotateLAPS {
    
    <#
    .SYNOPSIS
        Rotates the Local Administrator Password Solution (LAPS) password for Intune managed devices based on specified criteria.

    .DESCRIPTION
        The Invoke-IBMrotateLAPS function allows you to trigger a rotation of the LAPS password for Intune managed devices.
        You can specify individual devices using `DeviceId`, `GroupName`, `DeviceName`, or `OS`. 
        Additionally, you can choose to rotate the password for all devices or select specific devices/groups interactively.

    .NOTES
        Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
        Version: 1.3
        Date: 2024-08-12

        Changelog:
        - 2024-08-01: 1.0 Initial version
        - 2024-08-03: 1.1 Added filtering for only Windows Devices
        - 2024-08-06: 1.2
            - Added batching / batch requests for large device collections and speed improvements (seperate function: Invoke-IBMGrapAPIBatching)
            - Aligment of all Action functions to the same structure
        - 2024-08-12: 1.3
            - Optimized handling of unsupported OS

    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Specify the ID of the individual device to rotate the LAPS password.")]
        [string]$DeviceId,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group to which the devices belong.")]
        [string]$GroupName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the individual device to rotate the LAPS password.")]
        [string]$DeviceName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the operating system of the devices to rotate the LAPS password. For example, 'Windows' or 'iOS'.")]
        [string[]]$OS,
        
        [parameter(Mandatory = $false, HelpMessage = "Rotate the LAPS password for all devices managed by Intune.")]
        [switch]$AllDevices,

        [parameter(Mandatory = $false, HelpMessage = "Interactively select specific devices to rotate the LAPS password.")]
        [switch]$SelectDevices,

        [parameter(Mandatory = $false, HelpMessage = "Interactively select a specific group of devices to rotate the LAPS password.")]
        [switch]$SelectGroup
    )

    # Definition of supported OS for this remote action
    $SupportetOS = @("Windows")

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

    # Rotate LAPS password each device
    $batchingParams = @{
        "Objects2Process"       = $CollectionDevicesInfo.id
        "ActionURI"             = "deviceManagement/managedDevices/{0}/rotateLocalAdminPassword/"
        "Method"                = "POST"
        "GraphVersion"          = "beta"
		"BodySingle"            = @{}
        "ActionTitle"           = "Rotate LAPS password"
    } 
    Invoke-IBMGrapAPIBatching @batchingParams

}
