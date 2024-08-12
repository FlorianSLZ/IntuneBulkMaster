function Remove-IBMprimaryUser {

    <#
    .SYNOPSIS
        Removes the primary user from Intune managed devices based on specified criteria.

    .DESCRIPTION
        The Remove-IBMprimaryUser function allows you to remove the primary user from Intune managed devices.
        You can specify individual devices by DeviceId, GroupName, DeviceName, or OS.
        Additionally, you can choose to remove primary users from all devices or select devices/groups interactively.

    .NOTES
        Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
        Version: 1.2
        Date: 2024-08-12

        Changelog:
        - 2024-08-03: 1.0 Initial version
        - 2024-08-06: 1.1 
            - Added batching / batch requests for large device collections and speed improvements (seperate function: Invoke-IBMGrapAPIBatching)
            - Aligment of all Action functions to the same structure
        - 2024-08-12: 1.2
            - Optimized handling of unsupported OS
        
    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Specify the ID of the individual device to remove the primary user.")]
        [string]$DeviceId,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group to which the devices belong.")]
        [string]$GroupName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the individual device to remove the primary user.")]
        [string]$DeviceName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the operating system of the devices to remove the primary user. For example, 'Windows' or 'iOS'.")]
        [string[]]$OS,
        
        [parameter(Mandatory = $false, HelpMessage = "Remove the primary user from all devices managed by Intune.")]
        [switch]$AllDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select specific devices interactively to remove the primary user.")]
        [switch]$SelectDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select a specific group of devices interactively to remove the primary user.")]
        [switch]$SelectGroup
    )

    # Definition of supported OS for this remote action
    $SupportetOS = @("Windows", "macOS", "iOS", "iPadOS", "Android", "Linux (Ubuntu)")

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

    # Remove Primary User for each device
    $batchingParams = @{
        "Objects2Process"       = $CollectionDevicesInfo.Id
        "ActionURI"             = "deviceManagement/managedDevices('{0}')/users/`$ref"
		"Method"                = "DELETE"
        "GraphVersion"          = "beta"
		"BodySingle"            = @{}
        "ActionTitle"           = "Remove Primary User"
    } 
    Invoke-IBMGrapAPIBatching @batchingParams

}
