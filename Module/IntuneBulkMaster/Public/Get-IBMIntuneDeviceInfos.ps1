function Get-IBMIntuneDeviceInfos {

    <#
    .SYNOPSIS
        Retrieves the Intune device IDs based on specified criteria.

    .DESCRIPTION
        The Get-IntuneDeviceInfos function allows you to retrieve Intune managed device IDs by specifying criteria such as DeviceId, GroupName, DeviceName, and OS. 
        You can also choose to retrieve all devices or select devices interactively.

    .NOTES
        Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
        Version: 1.4
        Date: 2024-08-12

        Changelog:
        - 2024-08-01: 1.0 Initial version
        - 2024-08-03: 1.1 
            - Renamed to Get-IBMIntuneDeviceInfos
            - Added support for nested group memberships
            - Added support for Intune device IDs or all Info output
        - 2024-08-06: 1.2 Added support for passing multiple OS types
        - 2024-08-07: 1.3 Added support for retrieving devices by serial number(s)
        - 2024-08-12: 1.4 Improved getting devices from group by name / nested groups
        
    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Retrieve all information about the devices.")]
        [switch]$AllDeviceInfo,

        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the individual device to retrieve.")]
        [string]$DeviceName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the name of the group to which the devices belong.")]
        [string]$GroupName,
        
        [parameter(Mandatory = $false, HelpMessage = "Specify the operating system(s) of the devices to retrieve. For example, 'Windows' and/or 'iOS'.")]
        [ValidateSet("Windows","macOS","iOS","iPadOS","Android","Linux (Ubuntu)","")]
        [string[]]$OS,

        [parameter(Mandatory = $false, HelpMessage = "Specify the serial number of the device to retrieve.")]
        [string]$Serialnumber,

        [parameter(Mandatory = $false, HelpMessage = "Specify the serial numbers of the devices to retrieve.")]
        [string]$Serialnumbers,
        
        [parameter(Mandatory = $false, HelpMessage = "Retrieve all devices managed by Intune.")]
        [switch]$AllDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select specific devices interactively to retrieve.")]
        [switch]$SelectDevices,

        [parameter(Mandatory = $false, HelpMessage = "Select a specific group of devices interactively to retrieve.")]
        [switch]$SelectGroup,

        [parameter(Mandatory = $false, HelpMessage = "Specify the ID of the individual device to retrieve.")]
        [string]$DeviceId

        
    )

    # Function to recursively get all device IDs from a group, including nested groups
    function Get-GroupMemberTypeDevice {
        param (
            [string]$groupId
        )

        # Get members of the group
        $members = Invoke-IBMPagingRequest -Uri "https://graph.microsoft.com/v1.0/groups/$groupId/members"

        $EntraDeviceIds = @()

        $EntraDeviceIds = ($members | Where-Object { $_.'@odata.type' -eq '#microsoft.graph.device' }).deviceId
        $EntraGroupIds = ($members | Where-Object { $_.'@odata.type' -eq '#microsoft.graph.group' }).id

        foreach ($group in $EntraGroupIds) {
            $nestedGroupEntraDeviceIds = Get-GroupMemberTypeDevice -groupId $group
            $EntraDeviceIds += $nestedGroupEntraDeviceIds
        }

        $EntraDeviceIds = $EntraDeviceIds -gt 0 | Sort-Object -Unique
        return $EntraDeviceIds
    }

    $filter = $null
    $IntuneDeviceInfos = $null

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
            $IntuneDeviceInfos = @()
            $batchingParams = @{
                "Objects2Process"       = $EntraDeviceIds
                "ActionURI"             = "deviceManagement/managedDevices?`$filter=azureADDeviceId eq '{0}'"
                "Method"                = "GET"
                "GraphVersion"          = "v1.0"
                "BodySingle"            = @{}
                "ActionTitle"           = "Get Device by azureADDeviceId"
            } 
            $IntuneDeviceInfos = Invoke-IBMGrapAPIBatching @batchingParams

        } else {
            Write-Output "Group ""$GroupName"" not found."
            break
        }
    } elseif ($DeviceName) {
        $filter = "deviceName eq '$DeviceName'"
    } elseif ($OS) {
        #$filter = "operatingSystem eq '$OS'"
        $osFilters = $OS | ForEach-Object { "operatingSystem eq '$_'" }
        $filter = "(" + ($osFilters -join " or ") + ")"

    } elseif($Serialnumber){
        $filter = "serialNumber eq '$Serialnumber'"
    } elseif($Serialnumbers){
        $serials = $Serialnumbers -split ","
        $serialFilters = $serials | ForEach-Object { "serialNumber eq '$_'" }
        $filter = "(" + ($serialFilters -join " or ") + ")"

        $Serialnumbers = $Serialnumbers.Where({ $_ -ne "" })

        $batchingParams = @{
            "Objects2Process"       = $Serialnumbers
            "ActionURI"             = "deviceManagement/managedDevices?`$filter=serialNumber eq '{0}'"
            "Method"                = "GET"
            "GraphVersion"          = "beta"
            "BodySingle"            = @{}
            "ActionTitle"           = "Get Device by Serial Number"
        } 
        $IntuneDeviceInfos = Invoke-IBMGrapAPIBatching @batchingParams


    }else {
        $filter = $null
    }

    $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices"
    if ($filter) {
        $uri += "?`$filter=$filter"
    } elseif($DeviceId){
        $uri += "/$DeviceId"
        $singleDevice = Invoke-MgGraphRequest -Uri $uri -Method GET
        return $singleDevice
        break
    }

    if($IntuneDeviceInfos){
        $IntuneDeviceInfos = Invoke-IBMPagingRequest -Uri $uri
    }


    if($SelectDevices){
        $IntuneDeviceInfos = ($IntuneDeviceInfos | Out-GridView -PassThru -Title "Select Devices")
    }

    if($AllDeviceInfo){
        return $IntuneDeviceInfos
    }else{
       return $IntuneDeviceInfos.id 
    }
}
