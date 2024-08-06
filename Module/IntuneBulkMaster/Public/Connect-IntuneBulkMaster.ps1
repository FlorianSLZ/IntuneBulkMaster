function Connect-IntuneBulkMaster {

    <#
    .SYNOPSIS
        Establishes a connection to Microsoft Graph with the required scopes for Intune device management.

    .DESCRIPTION
        The Connect-IntuneBulkMaster function connects to Microsoft Graph using user authentication.
        It ensures any existing Graph session is disconnected before establishing a new session with the necessary scopes for managing Intune devices.

    .NOTES
        Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
        Version: 1.1
        Date: 2024-08-06

        Changelog:
        - 2024-08-01: 1.0 Initial version
        - 2024-08-06: 1.1 Added Welcome message with user information
        
    #>

    param ()

    # Disconnect old session if exists
    $mgContext = Get-MgContext
    if ($mgContext -and $mgContext.AppName) {
        Write-Verbose "Terminating existing Graph session"
        Disconnect-Graph | Out-Null
    }

    Write-Verbose "Establishing new Graph connection via user authentication"
    $scopes = @(
        "DeviceManagementManagedDevices.ReadWrite.All", 
        "Device.Read.All",
        "DeviceManagementManagedDevices.PrivilegedOperations.All"
    )
    Connect-MgGraph -Scopes $scopes -NoWelcome

    Write-Verbose "New Graph connection established: $MSGraph"

    $mgContext = Get-MgContext
    Write-Host "Welcome to IntuneBulkMaster" -ForegroundColor Green
    Write-Host "You are connected as $($mgContext.Account)"
}
