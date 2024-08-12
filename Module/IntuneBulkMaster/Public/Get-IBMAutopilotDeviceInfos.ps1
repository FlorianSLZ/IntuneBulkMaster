function Get-IBMAutopilotDeviceInfos {

    <#
    .SYNOPSIS
        Retrieves the Autopilot device Infos based on specified criteria.

    .DESCRIPTION
        The Get-IBMAutopilotDeviceInfos function allows you to retrieve Autopilot managed device Infos by Serialnumber(s).

    .NOTES
        Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
        Version: 1.0
        Date: 2024-08-11

        Changelog:
        - 2024-08-11: 1.0 Initial version
        
    #>

    param (

        [parameter(Mandatory = $false, HelpMessage = "Specify the serial number of the device to retrieve.")]
        [string]$Serialnumber,

        [parameter(Mandatory = $false, HelpMessage = "Specify the serial numbers of the devices to retrieve.")]
        [string]$Serialnumbers
        
    )


    $AutopilotDeviceInfos = $null

    if($Serialnumbers -or $Serialnumber){

        if($Serialnumber){
            $Serialnumbers = $Serialnumber
        } 
        
        $Serialnumbers = $Serialnumbers.Where({ $_ -ne "" })

        $batchingParams = @{
            "Objects2Process"       = $Serialnumbers
            "ActionURI"             = "deviceManagement/windowsAutopilotDeviceIdentities?`$filter=contains(serialNumber,'{0}')"
            "Method"                = "GET"
            "GraphVersion"          = "beta"
            "BodySingle"            = @{}
            "ActionTitle"           = "Get Device by Serial Number"
        } 
        $AutopilotDeviceInfos = Invoke-IBMGrapAPIBatching @batchingParams
    }else{
        # get all autopilot devices
        $AutopilotDeviceInfos = Invoke-IBMPagingRequest -Uri "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeviceIdentities"
    }

    return $AutopilotDeviceInfos

}
