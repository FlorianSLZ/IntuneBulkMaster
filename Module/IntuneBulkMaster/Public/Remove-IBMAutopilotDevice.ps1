function Remove-IBMAutopilotDevice {

    <#
    .SYNOPSIS
        Removes a device from Autopilot based on its Intune Device ID without deleting the device from Intune.

    .DESCRIPTION
        The Remove-IBMAutopilotDevice function allows you to remove a device from Autopilot.
        Devices are identified by their Intune Device ID. This function will not delete the device from Intune itself,
        only from the Autopilot service.

    .NOTES
        Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
        Version: 1.0
        Date: 2024-08-03

        Changelog:
        - 2024-08-03: 1.0 Initial version

        
    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Specify the ID of the individual device to remove from Autopilot.")]
        [string]$DeviceId,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group to which the devices belong.")]
        [string]$GroupName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the individual device to remove from Autopilot.")]
        [string]$DeviceName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the operating system of the devices to remove from Autopilot. For example, 'Windows' or 'iOS'.")]
        [string]$OS,

        [parameter(Mandatory = $false, HelpMessage = "Remove devices from Autopilot based on all Intune devices.")]
        [switch]$AllDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select specific devices interactively to remove from Autopilot.")]
        [switch]$SelectDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select a specific group of devices interactively to remove from Autopilot.")]
        [switch]$SelectGroup
    )


    # Function to get Autopilot device ID based on Intune Device ID
    function Get-AutopilotDeviceIdByIntuneId {
        param (
            [string]$SerialNumber
        )

        $uri = "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeviceIdentities?`$filter=contains(serialNumber,'$SerialNumber')"

        $autopilotDevices = Invoke-IBMPagingRequest -Uri $uri

        if ($autopilotDevices.Count -eq 0) {
            Write-Warning "No Autopilot device found for Intune Device ID: $IntuneDeviceId."
            return $null
        }

        return $autopilotDevices[0].id
    }

    # Definition of supported OS for this remote action
    $SupportetOS = @("Windows")
    
    # Get device IDs based on provided criteria
    if($AllDevices){
        $CollectionDevicesInfo = Get-IBMIntuneDeviceInfos -OS "Windows" -AllDeviceInfo # cause its only supported for them ;) 
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

    # Autopilot Object removal for each device
    $counter = 0
    foreach ($DeviceInfo in $CollectionDevicesInfo) {
        $counter++
        Write-Progress -Id 0 -Activity "Autopilot Object removal" -Status "Processing $($counter) of $($CollectionDevicesInfo.count)" -CurrentOperation $computer -PercentComplete (($counter/$CollectionDevicesInfo.Count) * 100)

        if($DeviceInfo.operatingSystem -notin $SupportetOS){
            Write-Warning "Autopilot Object removal is only supported for ""$SupportetOS"" devices. Skipping device ID: $($DeviceInfo.id)"
            continue
        }

        if($DeviceInfo.serialNumber.Length -lt 4){
            Write-Warning "No serial number found for device ID: $($DeviceInfo.id). Skipping device."
            continue
        }

        $autopilotDeviceId = Get-AutopilotDeviceIdByIntuneId -SerialNumber $DeviceInfo.serialNumber

        if ($autopilotDeviceId) {
            $uri = "https://graph.microsoft.com/v1.0/deviceManagement/windowsAutopilotDeviceIdentities/$autopilotDeviceId"

            try {
                $response = Invoke-MgGraphRequest -Method DELETE -Uri $uri
                Write-Verbose "Autopilot device with ID: $autopilotDeviceId removed successfully. $response"
            } catch {
                Write-Output "An error occurred while removing Autopilot device ID: $autopilotDeviceId. Error: $_"
            }
        }else{
            Write-Warning "No Autopilot device found for Serialnumber: $($DeviceInfo.serialNumber)."
        }
    }
}
