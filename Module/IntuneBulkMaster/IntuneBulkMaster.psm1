<#
.SYNOPSIS
    Script that initiates the IntuneBulkMaster module
.NOTES
    Author: Florian Salzman / @FlorianSLZ / https://scloud.work
#>
[CmdletBinding()]
Param(
    # Global variables
)
Process {
    # Locate all the public and private function specific files
    $PublicFunctions = Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath "Public") -Filter "*.ps1" -ErrorAction SilentlyContinue
    $PrivateFunctions = Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath "Private") -Filter "*.ps1" -ErrorAction SilentlyContinue

    # Dot source the function files
    foreach ($FunctionFile in @($PublicFunctions + $PrivateFunctions)) {
        try {
            . $FunctionFile.FullName -ErrorAction Stop
        }
        catch [System.Exception] {
            Write-Error -Message "Failed to import function '$($FunctionFile.FullName)' with error: $($_.Exception.Message)"
        }
    }

    Export-ModuleMember -Function $PublicFunctions.BaseName -Alias *
}
