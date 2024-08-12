function Set-IBMGroupTag {

    <#
    .SYNOPSIS
        Sets the Autopilot group tag for devices in Intune.

    .DESCRIPTION
        The Set-IBMGroupTag function allows you to set the group tag for devices in Intune based on specified criteria. 
        You can specify the device ID, group name, device name, operating system, or select devices interactively.

    .NOTES
        Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
        Version: 1.1
        Date: 2024-08-12

        Changelog:
        - 2024-08-11: 1.0 Initial version
        - 2024-08-12: 1.1
            - Optimized handling of unsupported OS
        
    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Specify the ID of the individual device to set as personal-owned.")]
        [string]$DeviceId,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group to which the devices belong.")]
        [string]$GroupName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the individual device to set as personal-owned.")]
        [string]$DeviceName,
        
        [parameter(Mandatory = $false, HelpMessage = "Set all devices managed by Intune as personal-owned.")]
        [switch]$AllDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select specific devices interactively to set as personal-owned.")]
        [switch]$SelectDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select a specific group of devices interactively to set as personal-owned.")]
        [switch]$SelectGroup,

        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group tag to assign.")]
        [string]$GroupTag

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

    # Setting devices to personal-owned 
    $body = @{
        groupTag = "$GroupTag"
    }

    $batchingParams = @{
        "Objects2Process"       = $CollectionDevicesInfo.Id
        "ActionURI"             = "deviceManagement/windowsAutopilotDeviceIdentities/{0}/UpdateDeviceProperties"
		"Method"                = "POST"
        "GraphVersion"          = "v1.0"
		"BodySingle"            =  $body
        "ActionTitle"           = "Group Tagging"
    } 
    Invoke-IBMGrapAPIBatching @batchingParams

}
