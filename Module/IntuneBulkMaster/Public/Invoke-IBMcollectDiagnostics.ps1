function Invoke-IBMcollectDiagnostics {

    <#
    .SYNOPSIS
        Initiates a request to collect diagnostic logs from Intune managed devices based on specified criteria.

    .DESCRIPTION
        The `Invoke-IBMcollectDiagnostics` function sends a request to collect diagnostic logs for Intune managed devices. 
        You can specify individual devices by `DeviceId`, `GroupName`, `DeviceName`, or `OS`. 
        Additionally, you can choose to collect logs from all devices or select specific devices/groups interactively.

    .NOTES
        Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
        Version: 1.0
        Date: 2024-08-01
    #>
    
    param (
        [parameter(Mandatory = $false, HelpMessage = "Specify the ID of the individual device to collect diagnostic logs.")]
        [string]$DeviceId,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group containing devices to collect diagnostic logs.")]
        [string]$GroupName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the individual device to collect diagnostic logs.")]
        [string]$DeviceName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the operating system of the devices to collect diagnostic logs. For example, 'Windows' or 'iOS'.")]
        [string]$OS,
        
        [parameter(Mandatory = $false, HelpMessage = "Collect diagnostic logs from all devices managed by Intune.")]
        [switch]$AllDevices,

        [parameter(Mandatory = $false, HelpMessage = "Interactively select specific devices to collect diagnostic logs.")]
        [switch]$SelectDevices,

        [parameter(Mandatory = $false, HelpMessage = "Interactively select a specific group of devices to collect diagnostic logs.")]
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
        Write-Warning "No devices found based on the provided criteria."
        return
    }

    # create Device Log Collection Request for each device
    $counter = 0
    foreach ($deviceId in $deviceIds) {
        $counter++
        Write-Progress -Id 0 -Activity "create Device Log Collection Request" -Status "Processing $($counter) of $($deviceIds.count)" -CurrentOperation $computer -PercentComplete (($counter/$deviceIds.Count) * 100)

        $uri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/$deviceId/createDeviceLogCollectionRequest"
        
        try {
            $response = Invoke-MgGraphRequest -Method POST -Uri $uri
            Write-Verbose "create Device Log Collection Request for device ID: $deviceId. $Response"
        } catch {
            Write-Output "An error occurred while create Device Log Collection Request for device ID: $deviceId. Error: $_"
        }
    }
}

