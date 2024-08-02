function Get-IntuneDeviceIDs {

    <#
    .SYNOPSIS
        Retrieves the Intune device IDs based on specified criteria.

    .DESCRIPTION
        The Get-IntuneDeviceIDs function allows you to retrieve Intune managed device IDs by specifying criteria such as DeviceId, GroupName, DeviceName, and OS. 
        You can also choose to retrieve all devices or select devices interactively.

    .NOTES
        Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
        Version: 1.0
        Date: 2024-08-01
    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Specify the ID of the individual device to retrieve.")]
        [string]$DeviceId,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group to which the devices belong.")]
        [string]$GroupName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the individual device to retrieve.")]
        [string]$DeviceName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the operating system of the devices to retrieve. For example, 'Windows' or 'iOS'.")]
        [string]$OS,
        
        [parameter(Mandatory = $false, HelpMessage = "Retrieve all devices managed by Intune.")]
        [switch]$AllDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select specific devices interactively to retrieve.")]
        [switch]$SelectDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select a specific group of devices interactively to retrieve.")]
        [switch]$SelectGroup
    )

    $filter = $null

    if($SelectGroup){
        $GroupsAll = Invoke-IBMPagingRequest -URI "https://graph.microsoft.com/v1.0/groups"
        $GroupName = ($GroupsAll | Select-Object displayName, description | Out-GridView -PassThru -Title "Select Group" -OutputMode Single).displayName
    }

    if ($GroupName) {
        # Get group ID by group name
        $group = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq '$GroupName'" -Method GET 
        if ($group.value) {
            $groupId = $group.value[0].id
            # Get devices in group
            $groupDevices = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/groups/$groupId/members" -Method GET
            $aadDeviceIds = ($groupDevices.value | Where-Object { $_.'@odata.type' -eq '#microsoft.graph.device' } ).deviceId

            # Map AAD device IDs to Intune managed device IDs
            $deviceIds = @()
            foreach ($aadDeviceId in $aadDeviceIds) {
                $managedDevice = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?`$filter=azureADDeviceId eq '$aadDeviceId'" -Method GET
                if ($managedDevice.value) {
                    $deviceIds += $managedDevice.value[0].id
                }
            }
            return $deviceIds
            break
        } else {
            Write-Output "Group not found."
            break
        }
    } elseif ($DeviceName) {
        $filter = "deviceName eq '$DeviceName'"
    } elseif ($OS) {
        $filter = "operatingSystem eq '$OS'"
    } else {
        $filter = $null
    }

    $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices"
    if ($filter) {
        $uri += "?`$filter=$filter"
    } elseif($DeviceId){
        $uri += "/$DeviceId"
        $singleDevice = Invoke-MgGraphRequest -Uri $uri -Method GET
        return $singleDevice.id
        break
    }

    $devices = Invoke-IBMPagingRequest -Uri $uri

    if($SelectDevices){

        $DeviceArray = @()
        foreach ($value in $devices) {
            $objectdetails = [pscustomobject]@{
                DeviceID = $value.id
                DeviceName = $value.deviceName
                Model = $value.model
                PrimaryUser = $value.userPrincipalName
            }
            $DeviceArray += $objectdetails
        }

        $deviceIDs = ($DeviceArray | Select-Object DeviceID, DeviceName, Model, PrimaryUser | Out-GridView -PassThru -Title "Select Devices").DeviceID
        
    }else{
        $deviceIDs = $devices.value.id
    }
    return $deviceIDs
}
