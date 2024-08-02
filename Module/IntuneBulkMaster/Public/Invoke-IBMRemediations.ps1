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
        Version: 1.0
        Date: 2024-08-01
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

    # Get All Remediations
    $RemediationAll = Invoke-IBMPagingRequest -URI "https://graph.microsoft.com/beta/deviceManagement/deviceHealthScripts"
    $RemediationSelected = $RemediationAll | Select-Object displayName, id | Out-GridView -PassThru -Title "Select Remediation"
    
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

    # Remediation trigger per device

    $RemediationBody = @"
{
	"ScriptPolicyId": "$($RemediationSelected.id)",
}
"@
    $counter = 0
    foreach ($deviceId in $deviceIds) {
        $counter++
        Write-Progress -Id 0 -Activity "Trigger Remediation" -Status "Processing $($counter) of $($deviceIds.count)" -CurrentOperation $deviceId -PercentComplete (($counter/$deviceIds.Count) * 100)

        $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices('$deviceId')/initiateOnDemandProactiveRemediation"
        
        try {
            $response = Invoke-MgGraphRequest -Method POST -Uri $uri -Body $RemediationBody -ContentType "application/json"
            Write-Verbose "Remediation triggered for device ID: $deviceId. $Response"
        } catch {
            Write-Output "An error occurred while triggering the remediation on device ID: $deviceId. `nError: $_"
        }
    }
}

