function Get-IBMIntuneDeviceInfos {

    <#
    .SYNOPSIS
        Retrieves the Intune device IDs based on specified criteria.

    .DESCRIPTION
        The Get-IntuneDeviceInfos function allows you to retrieve Intune managed device IDs by specifying criteria such as DeviceId, GroupName, DeviceName, and OS. 
        You can also choose to retrieve all devices or select devices interactively.

    .NOTES
        Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
        Version: 1.1
        Date: 2024-08-03

        Changelog:
        - 2024-08-01: 1.0 Initial version
        - 2024-08-03: 1.1 
            - Renamed to Get-IBMIntuneDeviceInfos
            - Added support for nested group memberships
            - Added support for Intune device IDs or all Info output
        
    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Specify the ID of the individual device to retrieve.")]
        [string]$DeviceId,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group to which the devices belong.")]
        [string]$GroupName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the individual device to retrieve.")]
        [string]$DeviceName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the operating system of the devices to retrieve. For example, 'Windows' or 'iOS'.")]
        [ValidateSet("Windows","macOS","iOS","Android","iPadOS", "Linux (Ubuntu)", "")]
        [string]$OS,
        
        [parameter(Mandatory = $false, HelpMessage = "Retrieve all devices managed by Intune.")]
        [switch]$AllDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select specific devices interactively to retrieve.")]
        [switch]$SelectDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select a specific group of devices interactively to retrieve.")]
        [switch]$SelectGroup,

        [parameter(Mandatory = $false, HelpMessage = "Retrieve all information about the devices.")]
        [switch]$AllDeviceInfo
    )

    # Function to recursively get all device IDs from a group, including nested groups
    function Get-GroupMemberTypeDevice {
        param (
            [string]$groupId
        )

        # Get members of the group
        $members = Invoke-IBMPagingRequest -Uri "https://graph.microsoft.com/v1.0/groups/$groupId/members"

        $EntraDeviceIds = @()

        foreach ($member in $members) {
            if ($member.'@odata.type' -eq '#microsoft.graph.device') {
                # If the member is a device, get its deviceId
                $EntraDeviceIds += $member.deviceId
            } elseif ($member.'@odata.type' -eq '#microsoft.graph.group') {
                # If the member is a group, recursively get device IDs from this group
                $nestedGroupEntraDeviceIds = Get-GroupMemberTypeDevice -groupId $member.id
                $EntraDeviceIds += $nestedGroupEntraDeviceIds
            }
        }

        return $EntraDeviceIds
    }

    $filter = $null

    if($SelectGroup){
        $GroupsAll = Invoke-IBMPagingRequest -URI "https://graph.microsoft.com/v1.0/groups"
        $GroupName = ($GroupsAll | Select-Object displayName, description | Out-GridView -Title "Select Group" -OutputMode Single).displayName
    }

    if ($GroupName) {
        # Get group ID by group name
        $group = Invoke-IBMPagingRequest -Uri "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq '$GroupName'"
        if ($group) {
            $groupId = $group[0].id
            
            # Get all device IDs from the group, including nested groups
            $EntraDeviceIds = Get-GroupMemberTypeDevice -groupId $groupId

            # Map Entra device IDs to Intune managed device IDs
            $IntuneDevices = @()
            foreach ($EntraDeviceId in $EntraDeviceIds) {
                $managedDevice = Invoke-IBMPagingRequest -Uri "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?`$filter=azureADDeviceId eq '$EntraDeviceId'" 
                if ($managedDevice) {
                    $IntuneDevices += $managedDevice[0]
                }
            }
            if($AllDeviceInfo){
                return $IntuneDevices
            }else{
               return $IntuneDevices.id 
            }
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

    $DeviceInfos = Invoke-IBMPagingRequest -Uri $uri

    if($SelectDevices){
        $DeviceInfos = ($DeviceInfos | Out-GridView -PassThru -Title "Select Devices")
    }

    if($AllDeviceInfo){
        return $DeviceInfos
    }else{
       return $DeviceInfos.id 
    }
}
