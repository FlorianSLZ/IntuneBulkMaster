#
# Module manifest for module 'IntuneBulkMaster'
#
# Generated by: Florian Salzmann
#
# Generated on: 2024-08-01
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'IntuneBulkMaster.psm1'

# Version number of this module.
ModuleVersion = '24.08.12.00'

# Supported PSEditions
CompatiblePSEditions = 'Desktop'

# ID used to uniquely identify this module
GUID = 'b00d1997-6697-4812-b53c-be9b00bbd394'

# Author of this module
Author = 'Florian Salzmann | @FlorianSLZ | https://scloud.work'

# Company or vendor of this module
CompanyName = 'scloud.work'

# Copyright statement for this module
Copyright = '(c) 2024 Florian Salzmann. GPL-3.0 license.'

# Description of the functionality provided by this module
Description = 'Easier bulk Actions for Microsoft Intune. 
The `IntuneBulkMaster` PowerShell module provides a set of functions for managing and interacting with Microsoft Intune. It is designed to perform bulk operations on Intune-managed devices, such as rebooting, collecting diagnostics, and rotating keys. This module facilitates efficient management of devices by allowing administrators to perform tasks across multiple devices or groups with ease.
'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @(
    "Microsoft.Graph.Authentication"
)

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @(
    "Connect-IntuneBulkMaster",
    "Get-IBMAutopilotDeviceInfos",
    "Get-IBMIntuneDeviceInfos",
    "Invoke-IBMGrapAPIBatching",
    "Invoke-IBMcollectDiagnostics",
    "Invoke-IBMPagingRequest",
    "Invoke-IBMpauseConfigurationRefresh",
    "Invoke-IBMReboot",
    "Invoke-IBMRemediations",
    "Invoke-IBMremoteLock",
    "Invoke-IBMrotateBitLockerKeys",
    "Invoke-IBMrotateFileVaultKey",
    "Invoke-IBMrotateLAPS",
    "Invoke-IBMshutDown",
    "Invoke-IBMSync",
    "Remove-IBMAutopilotDevice",
    "Remove-IBMprimaryUser",
    "Set-IBMCorporateOwned",
    "Set-IBMGroupTag",
    "Set-IBMIntuneDeviceName",
    "Set-IBMPersonalOwned"
)

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @("Intune", "Devices", "Bulk", "Management", "Microsoft", "Graph", "PowerShell")

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/FlorianSLZ/IntuneBulkMaster/blob/main/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/FlorianSLZ/IntuneBulkMaster'

        # A URL to an icon representing this module.
        IconUri = 'https://scloud.work/wp-content/uploads/IntuneBulkMaster-Icon.png'

        # ReleaseNotes of this module
        ReleaseNotes = 'https://github.com/FlorianSLZ/IntuneBulkMaster/blob/main/Module/IntuneBulkMaster/ReleaseNotes.md'

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
HelpInfoURI = 'https://scloud.work/IntuneBulkMaster/'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

