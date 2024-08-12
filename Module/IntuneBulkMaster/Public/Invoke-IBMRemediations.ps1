function Invoke-IBMRemediations {

    <#
    .SYNOPSIS
        Triggers proactive remediations for Intune managed devices based on specified criteria.

    .DESCRIPTION
        The Invoke-IBMRemediations function allows you to trigger proactive remediation scripts for Intune managed devices.
        You can specify individual devices by DeviceId, GroupName, DeviceName, or OS.
        Additionally, you can choose to trigger remediations for all devices or select devices/groups interactively. 


        Kudos to Andrew Taylor for the his initial function, which he wrote during my session at the #MEMSummit 2023 in Paris :D
        https://andrewstaylor.com/2023/09/06/remediations-on-demand-in-bulk/

    .NOTES
        Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
        Version: 1.3
        Date: 2024-08-12

        Changelog:
        - 2024-08-01: 1.0 Initial version
        - 2024-08-03: 1.1 Added filtering for only supported OS types
        - 2024-08-06: 1.2
            - Added batching / batch requests for large device collections and speed improvements (seperate function: Invoke-IBMGrapAPIBatching)
            - Aligment of all Action functions to the same structure
        - 2024-08-12: 1.3
            - Optimized handling of unsupported OS
        
    #>
    
    
    param (
        [parameter(Mandatory = $false, HelpMessage = "Specify the ID of the individual device to remediate.")]
        [string]$DeviceId,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group to which the devices belong.")]
        [string]$GroupName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the individual device to remediate.")]
        [string]$DeviceName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the operating system of the devices to remediate. For example, 'Windows' or 'iOS'.")]
        [string[]]$OS,
        
        [parameter(Mandatory = $false, HelpMessage = "Trigger remediation for all devices managed by Intune.")]
        [switch]$AllDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select specific devices interactively to remediate.")]
        [switch]$SelectDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select a specific group of devices interactively to remediate.")]
        [switch]$SelectGroup
    )

    # Definition of supported OS for this remote action
    $SupportetOS = @("Windows")

    if($OS -and $SupportetOS -notcontains $OS){
        Write-Warning "The specified operating system ""$OS"" is not supported for this action. Supported OS ""$SupportetOS""."
        return
    }

    # Get All Remediations
    $RemediationAll = Invoke-IBMPagingRequest -URI "https://graph.microsoft.com/beta/deviceManagement/deviceHealthScripts"
    $RemediationSelected = $RemediationAll | Select-Object displayName, id | Out-GridView -PassThru -Title "Select Remediation"

    # Remediation trigger boddy
    $RemediationBody = @"
{
	"ScriptPolicyId": "$($RemediationSelected.id)",
}
"@
        
    
    
    # Get device IDs based on provided criteria
    if($AllDevices){
        $CollectionDevicesInfo = Get-IBMIntuneDeviceInfos -AllDeviceInfo
    }elseif($SelectDevices){
        $CollectionDevicesInfo = Get-IBMIntuneDeviceInfos -SelectDevices -AllDeviceInfo 
    }elseif($SelectGroup){
        $CollectionDevicesInfo = Get-IBMIntuneDeviceInfos -SelectGroup -AllDeviceInfo
    }else{
        $CollectionDevicesInfo = Get-IBMIntuneDeviceInfos -DeviceId $DeviceId -GroupName $GroupName -DeviceName $DeviceName -OS $OS -AllDeviceInfo
    }

    # collection for unsupported OS
    $UnsupportedDevices = $CollectionDevicesInfo | Where-Object { $SupportetOS -notcontains $_.operatingSystem }
    if($UnsupportedDevices){
        Write-Warning "Unsuported devices for this action wont be processed: $($UnsupportedDevices.count)"
        Write-Host "Use -Verbose to show details."
        Write-Verbose $UnsupportedDevices.id
    }

    # filter out supported OS
    $CollectionDevicesInfo = $CollectionDevicesInfo | Where-Object { $SupportetOS -contains $_.operatingSystem }

    if (-not $CollectionDevicesInfo) {
        Write-Warning "No devices found based on the provided criteria."
        return
    }

    # Remediation on Demand each device
    $batchingParams = @{
        "Objects2Process"       = $CollectionDevicesInfo.id
        "ActionURI"             = "deviceManagement/managedDevices/{0}/initiateOnDemandProactiveRemediation/"
        "Method"                = "POST"
        "GraphVersion"          = "v1.0"
        "BodySingle"            = $RemediationBody
        "ActionTitle"           = "Remediation on Demand"
    } 
    Invoke-IBMGrapAPIBatching @batchingParams

}
