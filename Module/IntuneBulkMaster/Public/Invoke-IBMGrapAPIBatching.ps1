function Invoke-IBMGrapAPIBatching {

    <#
    .SYNOPSIS
        Executes a paged request to the Microsoft Graph API and retrieves all results.

    .DESCRIPTION
        The Invoke-IBMPagingRequest function handles pagination when making requests to the Microsoft Graph API.
        It retrieves all pages of results from the specified URI and returns the complete collection of data.

    .NOTES
        Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
        Version: 1.0
        Date: 2024-08-05

        Changelog:
        - 2024-08-05: 1.0 Initial version
        
    #>


    param (
        [parameter(Mandatory = $true, HelpMessage = "Specify the collection of devices to process.")]
        [ValidateNotNullOrEmpty()]
        [array]$Objects2Process,
        
        [parameter(Mandatory = $true, HelpMessage = "Specify the URI for the Microsoft Graph API call, ID variable is {0}. e.g deviceManagement/managedDevices/{0}/syncDevice/")]
        [ValidateNotNullOrEmpty()]
        [string]$ActionURI, 

        [parameter(Mandatory = $true, HelpMessage = "Specify the HTTP method for the Microsoft Graph API call.")]
        [ValidateNotNullOrEmpty()]
        [string]$Method, 

        [parameter(Mandatory = $false, HelpMessage = "Readable title for Progress bar and log.")]
        [ValidateNotNullOrEmpty()]
        [string]$ActionTitle, 

        [parameter(Mandatory = $false, HelpMessage = "Specify the body for the Microsoft Graph API call. (optional)")]
        [ValidateNotNullOrEmpty()]
        [array]$BodySingle = @{}, 

        [parameter(Mandatory = $false, HelpMessage = "Graph version to use, default is v1.0.")]
        [ValidateNotNullOrEmpty()]
        [string]$GraphVersion = "v1.0", 

        [parameter(Mandatory = $false, HelpMessage = "Size of batches, max is 20.")]
        [ValidateNotNullOrEmpty()]
        [int]$BatchSize = 20, # Max is 20: https://learn.microsoft.com/en-us/graph/json-batching#batch-size-limitations

        [parameter(Mandatory = $false, HelpMessage = "Graph URI for batching / batch requests.")]
        [ValidateNotNullOrEmpty()]
        [string]$BatchURI = "https://graph.microsoft.com/$GraphVersion/`$batch"

    )


    if(!$ActionTitle){  $ActionTitle = "$ActionURI" }

    $ResponseCollection = [System.Collections.Generic.List[System.Object]]::new()

    for ($i = 0; $i -lt $Objects2Process.Length; $i += $BatchSize) {
        Write-Progress -Id 0 -Activity "$ActionTitle" -Status "Processing $($i) of $($Objects2Process.count)" -PercentComplete (($i/$Objects2Process.Count) * 100)
        Write-Verbose "Processing chunk starting at index $i" 

        # Calculate the end index for the current chunk
        $end = [math]::Min($i + $BatchSize, $Objects2Process.Length)

        # Handle single item case
        if ($end - $i -eq 1) {
            Write-Verbose "Processing last/single item at index $i"
            $requestParams = @{
                "Method"      = $Method
                "Uri"         = "https://graph.microsoft.com/$GraphVersion/$ActionURI" -f $($Objects2Process[$i]) 
                "ContentType" = "application/json"
                "Body"        = if ($BodySingle.Count -gt 0) { $BodySingle } else { @{} }
            }        
        }else{
            # Create the batch requests
            $requests = for ($j = $i; $j -lt $end; $j++) {
                [PSCustomObject]@{
                    "id"     = "$($j + 1)"
                    "Method" = $Method
                    "URL"    = $ActionURI -f $($Objects2Process[$j])
                    "Headers" = @{ "Content-Type" = "application/json" }
                    "Body"    = if ($BodySingle.Count -gt 0) { $BodySingle } else { @{} }
                }
            }
            
            # Convert the requests to JSON with appropriate depth
            $Body4requests = @{ "requests" = $requests } | ConvertTo-Json -Depth 4

            # Define the parameters for the request
            $requestParams = @{
                "Method"      = "POST"
                "Uri"         = $BatchURI
                "ContentType" = "application/json"
                "Body"        = $Body4requests
            }
        }
        
        # Send the request
        try {

            $response = Invoke-MgGraphRequest @requestParams
            Write-Verbose "Responses: $($response.responses.status)"

            $response.responses | ForEach-Object { $ResponseCollection.Add([pscustomobject]$PSItem.body) }

        }
        catch {
            Write-Error "Error occurred during request: $_"
        }
    }

    Write-Verbose "$ActionTitle of $($Objects2Process.count) devices completed."

    return $ResponseCollection.value
    
}
