function Invoke-IBMrotateFileVaultKey {

    <#
    .SYNOPSIS
        Rotates the FileVault encryption key for macOS devices managed by Intune.

    .DESCRIPTION
        The `Invoke-IBMrotateFileVaultKey` function triggers a rotation of the FileVault encryption key on macOS devices managed by Intune. 
        You can specify devices individually using `DeviceId`, `GroupName`, `DeviceName`, or `OS`. 
        Additionally, you can choose to rotate the FileVault key for all devices or select specific devices/groups interactively.

    .NOTES
        Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
        Version: 1.0
        Date: 2024-08-01
    #>
    
    param (
        [parameter(Mandatory = $false, HelpMessage = "Specify the ID of the individual device to rotate the FileVault key.")]
        [string]$DeviceId,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group that contains the devices for which to rotate the FileVault key.")]
        [string]$GroupName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the individual device to rotate the FileVault key.")]
        [string]$DeviceName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the operating system of the devices to rotate the FileVault key. For example, 'macOS'.")]
        [string]$OS,
        
        [parameter(Mandatory = $false, HelpMessage = "Rotate the FileVault key for all macOS devices managed by Intune.")]
        [switch]$AllDevices,

        [parameter(Mandatory = $false, HelpMessage = "Interactively select specific devices to rotate the FileVault key.")]
        [switch]$SelectDevices,

        [parameter(Mandatory = $false, HelpMessage = "Interactively select a specific group of devices to rotate the FileVault key.")]
        [switch]$SelectGroup
    )

    # Get device IDs based on provided criteria
    if($AllDevices){
        $deviceIds = Get-IntuneDeviceIDs -OS "macOS" # cause its only supported for them ;)  
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

    # rotate FileVault Key for each device
    $counter = 0
    foreach ($deviceId in $deviceIds) {
        $counter++
        Write-Progress -Id 0 -Activity "Rotate FileVault Key (macOS)" -Status "Processing $($counter) of $($deviceIds.count)" -CurrentOperation $computer -PercentComplete (($counter/$deviceIds.Count) * 100)

        $uri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/$deviceId/rotateFileVaultKey"
        
        try {
            $response = Invoke-MgGraphRequest -Method POST -Uri $uri
            Write-Verbose "FileVault Key rotation triggered for device ID: $deviceId. $Response"
        } catch {
            Write-Output "An error occurred while rotating FileVault Key for device ID: $deviceId. Error: $_"
        }
    }
}

