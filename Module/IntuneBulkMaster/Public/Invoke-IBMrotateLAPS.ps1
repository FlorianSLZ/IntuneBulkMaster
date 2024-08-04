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
        Version: 1.1
        Date: 2024-08-03

        Changelog:
        - 2024-08-01: 1.0 Initial version
        - 2024-08-03: 1.1 Added filtering for only Windows Devices

    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Specify the ID of the individual device to rotate the LAPS password.")]
        [string]$DeviceId,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group to which the devices belong.")]
        [string]$GroupName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the individual device to rotate the LAPS password.")]
        [string]$DeviceName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the operating system of the devices to rotate the LAPS password. For example, 'Windows' or 'iOS'.")]
        [string]$OS,
        
        [parameter(Mandatory = $false, HelpMessage = "Rotate the LAPS password for all devices managed by Intune.")]
        [switch]$AllDevices,

        [parameter(Mandatory = $false, HelpMessage = "Interactively select specific devices to rotate the LAPS password.")]
        [switch]$SelectDevices,

        [parameter(Mandatory = $false, HelpMessage = "Interactively select a specific group of devices to rotate the LAPS password.")]
        [switch]$SelectGroup
    )

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

    # rotate LAPS password for each device
    $counter = 0
    foreach ($DeviceInfo in $CollectionDevicesInfo) {
        $counter++
        Write-Progress -Id 0 -Activity "Rotate LAPS password" -Status "Processing $($counter) of $($CollectionDevicesInfo.count)" -CurrentOperation $computer -PercentComplete (($counter/$CollectionDevicesInfo.Count) * 100)

        if($DeviceInfo.operatingSystem -notin $SupportetOS){
            Write-Warning "LAPS password rotation is only supported for ""$SupportetOS"" devices. Skipping device ID: $($DeviceInfo.id)"
            continue
        }
        $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices/$($DeviceInfo.id)/rotateLocalAdminPassword"
        
        try {
            $response = Invoke-MgGraphRequest -Method POST -Uri $uri
            Write-Verbose "LAPS password rotation triggered for device ID: $deviceId. $Response"
        } catch {
            Write-Output "An error occurred while LAPS password rotatio for device ID: $deviceId. Error: $_" -ForgroundColor Red
        }
    }
}

