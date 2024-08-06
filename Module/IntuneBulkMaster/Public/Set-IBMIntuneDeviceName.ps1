function Set-IBMIntuneDeviceName {

    <#
    .SYNOPSIS
        Changes the device name for Intune managed devices based on specified criteria.

    .DESCRIPTION
        The Set-IBMIntuneDeviceName function allows you to change the device name for Intune managed devices.
        You can specify individual devices by DeviceId, GroupName, DeviceName, or OS.
        Additionally, you can choose to change names for all devices or select devices/groups interactively.


    .NOTES
        Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
        Version: 1.1
        Date: 2024-08-06

        Changelog:
        - 2024-08-03: 1.0 Initial version
        - 2024-08-06: 1.1 
            - Added batching / batch requests for large device collections and speed improvements (seperate function: Invoke-IBMGrapAPIBatching)
            - Aligment of all Action functions to the same structure
        
    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Specify the ID of the individual device to rotate the name for.")]
        [string]$DeviceId,

        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group to which the devices belong.")]
        [string]$GroupName,

        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the individual device to rotate the name for.")]
        [string]$DeviceName,

        [parameter(Mandatory = $false, HelpMessage = "Specify the operating system of the devices to rotate the name for. For example, 'Windows' or 'iOS'.")]
        [string[]]$OS,

        [parameter(Mandatory = $false, HelpMessage = "Rotate the name for all devices managed by Intune.")]
        [switch]$AllDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select specific devices interactively to rotate the name for.")]
        [switch]$SelectDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select a specific group of devices interactively to rotate the name for.")]
        [switch]$SelectGroup,

        [parameter(Mandatory=$true, HelpMessage = "Specify the prefix for the new device name.")]
        [string]$Prefix,

        [parameter(Mandatory=$false, HelpMessage = "Specify the type of suffix to append to the prefix. Choose between 'SerialNumber' or 'UniqueNumber'.")]
        [ValidateSet("SerialNumber","UniqueNumber")]
        [string]$SuffixType,

        [parameter(Mandatory=$false, HelpMessage = "Specify the length of the unique number to generate if 'UniqueNumber' is selected for SuffixType.")]
        [int]$UniqueNumberLength = 4,

        [parameter(Mandatory = $false, HelpMessage = "Confirm custoff for operation for too long device names (Windows 15 characters).")]
        [switch]$ConfirmCutOff
    )


    # Definition of supported OS for this remote action
    $SupportetOS = @("Windows", "macOS", "iOS", "iPadOS", "Android", "Linux (Ubuntu)")

    if($OS -and $SupportetOS -notcontains $OS){
        Write-Warning "The specified operating system ""$OS"" is not supported for this action. Supported OS ""$SupportetOS""."
        return
    }elseif ($OS) {
        $SupportetOS = @($OS)
    }

    if ($SuffixType -eq "UniqueNumber") {
        $existingDevices = Invoke-IBMPagingRequest -Uri "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices"
        Write-Verbose "Existing devices: $($existingDevices.deviceName)"

    }
        
    # Get device IDs based on provided criteria
    if($AllDevices){
        $CollectionDevicesInfo = Get-IBMIntuneDeviceInfos -AllDeviceInfo -OS $SupportetOS
    }elseif($SelectDevices){
        $CollectionDevicesInfo = Get-IBMIntuneDeviceInfos -SelectDevices -AllDeviceInfo -OS $SupportetOS
    }elseif($SelectGroup){
        $CollectionDevicesInfo = Get-IBMIntuneDeviceInfos -SelectGroup -AllDeviceInfo -OS $SupportetOS
    }else{
        $CollectionDevicesInfo = Get-IBMIntuneDeviceInfos -DeviceId $DeviceId -GroupName $GroupName -DeviceName $DeviceName -OS $SupportetOS -AllDeviceInfo
    }

    if (-not $CollectionDevicesInfo) {
        Write-Warning "No devices found based on the provided criteria."
        return
    }


    # Create new Intune Device Name for each device
    foreach ($IntuneDevice in $CollectionDevicesInfo) {

        
        # Get the device details to retrieve the serial number if needed
        if ($SuffixType -eq "SerialNumber") {

            if ($null -eq $($IntuneDevice.serialNumber)) {
                Write-Error "Serial number not found for device ID $($IntuneDevice.Id)"
                return
            }
            
            $newDeviceName = "$Prefix$($IntuneDevice.serialNumber)"

        } elseif ($SuffixType -eq "UniqueNumber") {
            do {
                $suffix = -join ((48..57)  | Get-Random -Count $UniqueNumberLength | ForEach-Object {[char]$_}) 
                $newDeviceName = "$Prefix$suffix"
                Write-Verbose "Checking for existing device name $newDeviceName"
            } while (($existingDevices.deviceName -contains $newDeviceName))
        } else {
            $newDeviceName = "$Prefix"
        }

        if (!$ConfirmCutOff -and $newDeviceName.Length -gt 15) {
            # ask fot shorten devicename to 15 characters
            Write-Warning "The new device name $newDeviceName is longer than 15 characters."
            $confirm = Read-Host "Do you want to cut the name to 15 characters? (Y/N)"
            if ($confirm -eq "Y") {
                $newDeviceName = $newDeviceName.Substring(0,15)
            }else{
                Write-Warning "Device name not set for device ID $($IntuneDevice.Id)"
                return
            }
        }elseif ($newDeviceName.Length -gt 15) {    
            $newDeviceName = $newDeviceName.Substring(0,15)
        }

        $IntuneDevice | Add-Member -MemberType NoteProperty -Name "NewDeviceName" -Value $newDeviceName -Force
        Write-Verbose "Devicename for $($IntuneDevice.deviceName) will be set to $newDeviceName"

    }

    # Prepare the request body
    $UpdateBody = @{
        deviceName = $newDeviceName
    }

    # Set Intune Device Name for each device
    $batchingParams = @{
        "Objects2Process"       = $CollectionDevicesInfo.Id
        "ActionURI"             = "deviceManagement/managedDevices/{0}/setDeviceName/"
		"Method"                = "POST"
        "GraphVersion"          = "beta"
		"BodySingle"            = $UpdateBody
        "ActionTitle"           = "Set Intune Device Name"
    } 
    Invoke-IBMGrapAPIBatching @batchingParams

}
