function Invoke-IBMPagingRequest {

    <#
    .SYNOPSIS
        Executes a paged request to the Microsoft Graph API and retrieves all results.

    .DESCRIPTION
        The Invoke-IBMPagingRequest function handles pagination when making requests to the Microsoft Graph API.
        It retrieves all pages of results from the specified URI and returns the complete collection of data.

    .NOTES
        Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
        Version: 1.0
        Date: 2024-08-01
    #>


    param (
        [parameter(Mandatory = $true, HelpMessage = "Specify the URI for the Microsoft Graph API GET request.")]
        [ValidateNotNullOrEmpty()]
        [string]$URI

    )

    $GraphResponseFirst = (Invoke-MgGraphRequest -uri $URI -Method GET -OutputType PSObject)
    $GraphResponseCollection = $GraphResponseFirst.value
    
    $GraphNextLink = $GraphResponseFirst."@odata.nextLink"
    
    while ($null -ne $GraphNextLink) {
        $GraphResponseAll = (Invoke-MGGraphRequest -Uri $GraphNextLink -Method GET -outputType PSObject)
        $GraphNextLink = $GraphResponseAll."@odata.nextLink"
        $GraphResponseCollection += $GraphResponseAll.value
    }
    
    return $GraphResponseCollection
}