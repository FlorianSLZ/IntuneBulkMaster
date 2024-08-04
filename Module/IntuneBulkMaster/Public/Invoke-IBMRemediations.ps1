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
        Version: 1.1
        Date: 2024-08-03

        Changelog:
        - 2024-08-01: 1.0 Initial version
        - 2024-08-03: 1.1 Added filtering for only supported OS types
        
    #>
    
    
    param (
        [parameter(Mandatory = $false, HelpMessage = "Specify the ID of the individual device to remediate.")]
        [string]$DeviceId,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group to which the devices belong.")]
        [string]$GroupName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the individual device to remediate.")]
        [string]$DeviceName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the operating system of the devices to remediate. For example, 'Windows' or 'iOS'.")]
        [string]$OS,
        
        [parameter(Mandatory = $false, HelpMessage = "Trigger remediation for all devices managed by Intune.")]
        [switch]$AllDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select specific devices interactively to remediate.")]
        [switch]$SelectDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select a specific group of devices interactively to remediate.")]
        [switch]$SelectGroup
    )

    # Definition of supported OS for this remote action
    $SupportetOS = @("Windows")

    # Get All Remediations
    $RemediationAll = Invoke-IBMPagingRequest -URI "https://graph.microsoft.com/beta/deviceManagement/deviceHealthScripts"
    $RemediationSelected = $RemediationAll | Select-Object displayName, id | Out-GridView -PassThru -Title "Select Remediation"
    
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

    if (-not $CollectionDevicesInfo) {
        Write-Warning "No devices found based on the provided criteria."
        return
    }

    # Remediation trigger per device

    $RemediationBody = @"
{
	"ScriptPolicyId": "$($RemediationSelected.id)",
}
"@

    $counter = 0
    foreach ($DeviceInfo in $CollectionDevicesInfo) {
        $counter++
        Write-Progress -Id 0 -Activity "Trigger Remediation" -Status "Processing $($counter) of $($CollectionDevicesInfo.count)" -CurrentOperation $computer -PercentComplete (($counter/$CollectionDevicesInfo.Count) * 100)

        if($DeviceInfo.operatingSystem -notin $SupportetOS){
            Write-Warning "Trigger Remediation is only supported for ""$SupportetOS"" devices. Skipping device ID: $($DeviceInfo.id)"
            continue
        }
        $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices//$($DeviceInfo.id)/initiateOnDemandProactiveRemediation"
        
        try {
            $response = Invoke-MgGraphRequest -Method POST -Uri $uri -Body $RemediationBody -ContentType "application/json"
            Write-Verbose "Trigger Remediation for device ID: $($DeviceInfo.id). $Response"
        } catch {
            Write-Error "An error occurred while Trigger Remediation for device ID: $($DeviceInfo.id). Error: $_"
        }
    }

}

