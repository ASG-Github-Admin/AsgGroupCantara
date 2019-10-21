function Start-CantaraScheduler {

    <#
    .SYNOPSIS
    Starts the Cantara scheduler via the REST API.
    .DESCRIPTION
    Starts the Cantara scheduler via the REST API within an existing web reqest session.
    .EXAMPLE
    PS C:\> $URI = "http://servername.somedomain:1234/cantaraendpoint"
    PS C:\> Start-CantaraScheduler -URI $URI -WebSession CantaraSession
    Description
    -----------
    Starts the Cantara scheduler via Cantara REST API using the predefined URI and an existing web session object.
    .PARAMETER URI
    The URI for the Cantara Scheduler REST API endpoint.
    .PARAMETER WebSession
    The established web request session.
    .INPUTS
    System.String, WebRequestSession
    .OUTPUTS
    Boolean
    #>

    #Requires -Version 5.1

    [CmdLetBinding()]
    param (
        
        # Cantara scheduler REST API endpoint URI
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias("Endpoint", "URL")]
        [string] $URI,

        # Web request session
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.PowerShell.Commands.WebRequestSession] $WebSession
    )

    begin {

        # Error handling
        Set-StrictMode -Version "Latest"
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        $CallerEA = $ErrorActionPreference
        $ErrorActionPreference = "Stop"
    }

    process {

        try {

            #Create type names for xml output formatting in module

            # Invoke post REST API request
            $Params = @{
            
                Method      = "Post"
                Uri         = "$URI/service/scheduler/start"
                WebSession  = $WebSession
                ContentType = "application/json"
            }
            Write-Debug -Message "Invoking post REST API request to '$URI'"
            Write-Verbose -Message "Invoking post REST API request"
            $Req = Invoke-RestMethod @Params
            if (-not $Req) { throw "An error occurred invoking a post request with the Cantara REST API '$URI'." }

            # Verify the response from the request
            Write-Debug -Message "Verifying the response from the request: '$($Req.Message.'#text')'"
            Write-Verbose -Message "Verifying the response from the request"
            if ($Req.Message.'#text' -eq "Transaction Successful") {
                
                "The Cantara scheduler accepted the start request - $($Req.Message.'#text')" | Write-Debug
                Write-Verbose -Message "The Cantara scheduler accepted the start request"
            }
            else {

                "The Cantara scheduler did not accept the start request - $($Req.Message.'#text')" | Write-Warning
            }
        }
        catch { Write-Error -ErrorRecord $PSItem -EA $CallerEA }
    }
}