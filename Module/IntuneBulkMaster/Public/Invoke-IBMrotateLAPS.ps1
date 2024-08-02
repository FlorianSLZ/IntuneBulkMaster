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
        Version: 1.0
        Date: 2024-08-01
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

    # Get device IDs based on provided criteria
    if($AllDevices){
        $deviceIds = Get-IntuneDeviceIDs -AllDevices 
    }elseif($SelectDevices){
        $deviceIds = Get-IntuneDeviceIDs -SelectDevices
    }elseif($SelectGroup){
        $deviceIds = Get-IntuneDeviceIDs -SelectGroup
    }else{
        $deviceIds = Get-IntuneDeviceIDs -DeviceId $DeviceId -GroupName $GroupName -DeviceName $DeviceName -OS $OS 
    }

    if (-not $deviceIds) {
        Write-Output "No devices found based on the provided criteria."
        return
    }

    # Rotate LAPS password for each device
    $counter = 0
    foreach ($deviceId in $deviceIds) {
        $counter++
        Write-Progress -Id 0 -Activity "Rotate LAPS Password" -Status "Processing $($counter) of $($deviceIds.count)" -CurrentOperation $computer -PercentComplete (($counter/$deviceIds.Count) * 100)

        $uri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/$deviceId/rotateLocalAdminPassword"
        
        try {
            $response = Invoke-MgGraphRequest -Method POST -Uri $uri
            Write-Verbose "LAPS password rotation triggered for device ID: $deviceId. $Response"
        } catch {
            Write-Output "An error occurred while syncing device ID: $deviceId. Error: $_"
        }
    }
}

