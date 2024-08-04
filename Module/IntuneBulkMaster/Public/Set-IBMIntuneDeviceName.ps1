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
        Version: 1.0
        Date: 2024-08-03

        Changelog:
        - 2024-08-03: 1.0 Initial version
        
    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Specify the ID of the individual device to rotate the name for.")]
        [string]$DeviceId,

        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group to which the devices belong.")]
        [string]$GroupName,

        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the individual device to rotate the name for.")]
        [string]$DeviceName,

        [parameter(Mandatory = $false, HelpMessage = "Specify the operating system of the devices to rotate the name for. For example, 'Windows' or 'iOS'.")]
        [string]$OS,

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

    # Get device IDs based on provided criteria
    if($AllDevices){
        $deviceIds = Get-IBMIntuneDeviceInfos -AllDevices 
    }elseif($SelectDevices){
        $deviceIds = Get-IBMIntuneDeviceInfos -SelectDevices
    }elseif($SelectGroup){
        $deviceIds = Get-IBMIntuneDeviceInfos -SelectGroup
    }else{
        $deviceIds = Get-IBMIntuneDeviceInfos -DeviceId $DeviceId -GroupName $GroupName -DeviceName $DeviceName -OS $OS 
    }

    if (-not $deviceIds) {
        Write-Warning "No devices found based on the provided criteria."
        return
    }

    if ($SuffixType -eq "UniqueNumber") {
        $existingDevices = Invoke-IBMPagingRequest -Uri "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices"
        Write-Verbose "Existing devices: $($existingDevices.deviceName)"

    }

    # Set Intune Device Name for each device
    $counter = 0
    foreach ($deviceId in $deviceIds) {
        $counter++
        Write-Progress -Id 0 -Activity "Set Intune Device Name" -Status "Processing $($counter) of $($deviceIds.count)" -CurrentOperation $computer -PercentComplete (($counter/$deviceIds.Count) * 100)

        # Get the device details to retrieve the serial number if needed
        if ($SuffixType -eq "SerialNumber") {
            $device = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/$DeviceId"

            if ($null -eq $device) {
                Write-Error "Device not found with ID $DeviceId"
                return
            }

            $serialNumber = $device.serialNumber

            if ($null -eq $serialNumber) {
                Write-Error "Serial number not found for device ID $DeviceId"
                return
            }
            
            $newDeviceName = "$Prefix$serialNumber"

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
                Write-Warning "Device name not set for device ID $DeviceId"
                return
            }
        }elseif ($newDeviceName.Length -gt 15) {    
            $newDeviceName = $newDeviceName.Substring(0,15)
        }

        # Prepare the request body
        $body = @{
            deviceName = $newDeviceName
        }

        # Convert the body to JSON
        $jsonBody = $body | ConvertTo-Json

        try{
            # Update the device name
        Write-Verbose "Setting device name to $newDeviceName for device ID $DeviceId"
        Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/beta/deviceManagement/managedDevices/$DeviceId/setDeviceName" -Body $jsonBody -ContentType "application/json"
        
        Write-Output "Device name set to $newDeviceName for device ID $DeviceId"

        }catch{
            Write-Error "An error occurred while setting device name for device ID $DeviceId. Error: $_"
            return
        }
        
    }
}

