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
        Version: 1.1
        Date: 2024-08-10

        Changelog:
        - 2024-08-07: 1.0 Initial version
        - 2024-08-10: 1.1
            - Added batching / batch requests for large device collections and speed improvements
        
    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Specify the ID of the individual device to remove from Autopilot.")]
        [string]$DeviceId,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group to which the devices belong.")]
        [string]$GroupName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the individual device to remove from Autopilot.")]
        [string]$DeviceName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the operating system of the devices to remove from Autopilot. For example, 'Windows' or 'iOS'.")]
        [string[]]$OS,

        [parameter(Mandatory = $false, HelpMessage = "Remove devices from Autopilot based on all Intune devices.")]
        [switch]$AllDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select specific devices interactively to remove from Autopilot.")]
        [switch]$SelectDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select a specific group of devices interactively to remove from Autopilot.")]
        [switch]$SelectGroup
    )


    function Get-AutoPilotDevicesBySerialNumbers {

        param (
            [string[]]$SerialNumbers,
            [int]$BatchSize = 20
        )

        $AutopilotDeviceCollection = [System.Collections.Generic.List[System.Object]]::new()

        for ($i = 0; $i -lt $SerialNumbers.Length; $i += $BatchSize) {

            Write-Verbose "Processing batch $([math]::Ceiling(($i + 1) / $BatchSize)) of $([math]::Ceiling($SerialNumbers.Length / $BatchSize))"

            # split data to chunks of batchSize
            $end = $i + $BatchSize - 1
            if ($end -ge $SerialNumbers.Length) { $end = $SerialNumbers.Length }
            $index = $i
            $requests = $SerialNumbers[$i..($end)] | ForEach-Object {
                [PSCustomObject]@{
                    'Id'     = ++$index
                    'Method' = 'GET'
                    'Url'    = "deviceManagement/windowsAutopilotDeviceIdentities?`$filter=contains(serialNumber,'{0}')" -f $PSItem
                }
            }
        
            $requestParams = @{
                'Method'      = 'Post'
                'Uri'         = 'https://graph.microsoft.com/v1.0/$batch'
                'ContentType' = 'application/json'
                'Body'        = @{
                    'requests' = @($requests)
                } | ConvertTo-Json
            }
            $response = Invoke-MgGraphRequest @requestParams
            # Invoke-MgGraphRequest deserializes request to a hashtable
            $response.responses | ForEach-Object { $AutopilotDeviceCollection.Add([pscustomobject]$PSItem.body) }
        }

        return $AutopilotDeviceCollection

    }

    # Definition of supported OS for this remote action
    $SupportetOS = @("Windows")

    if($OS -and $SupportetOS -notcontains $OS){
        Write-Warning "The specified operating system ""$OS"" is not supported for this action. Supported OS ""$SupportetOS""."
        return
    }elseif ($OS) {
        $SupportetOS = @($OS)
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

    # Get all Autopilot devices by serial numbers
    $autopilotDevices = (Get-AutoPilotDevicesBySerialNumbers -SerialNumbers $CollectionDevicesInfo.serialNumber).value.id
    
    # Autopilot Object removal each device
    $batchingParams = @{
        "Objects2Process"       = $autopilotDevices
        "ActionURI"             = "deviceManagement/windowsAutopilotDeviceIdentities/{0}/"
        "Method"                = "DELETE"
        "GraphVersion"          = "v1.0"
		"BodySingle"            = @{}
        "ActionTitle"           = "Autopilot Object removal"
    } 
    Invoke-IBMGrapAPIBatching @batchingParams

}
