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
        Version: 1.0
        Date: 2024-08-03

        Changelog:
        - 2024-08-03: 1.0 Initial version
        
    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Specify the ID of the individual device to remove the primary user.")]
        [string]$DeviceId,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group to which the devices belong.")]
        [string]$GroupName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the individual device to remove the primary user.")]
        [string]$DeviceName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the operating system of the devices to remove the primary user. For example, 'Windows' or 'iOS'.")]
        [string]$OS,
        
        [parameter(Mandatory = $false, HelpMessage = "Remove the primary user from all devices managed by Intune.")]
        [switch]$AllDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select specific devices interactively to remove the primary user.")]
        [switch]$SelectDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select a specific group of devices interactively to remove the primary user.")]
        [switch]$SelectGroup
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

    # Remove primary user from each device
    $counter = 0
    foreach ($deviceId in $deviceIds) {
        $counter++
        Write-Progress -Id 0 -Activity "Removing primary user from devices" -Status "Processing $($counter) of $($deviceIds.count)" -CurrentOperation $deviceId -PercentComplete (($counter/$deviceIds.Count) * 100)

        $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices('$deviceId')/users/`$ref"

        try {
            $response = Invoke-MgGraphRequest -Method DELETE -Uri $uri
            Write-Verbose "Primary user removed from device ID: $deviceId. $response"
        } catch {
            Write-Output "An error occurred while removing primary user from device ID: $deviceId. Error: $_"
        }
    }
}

