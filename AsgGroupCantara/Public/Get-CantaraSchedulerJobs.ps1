function Get-CantaraSchedulerJobs {

    <#
    .SYNOPSIS
    Gets the Cantara scheduler running jobs via the REST API.
    .DESCRIPTION
    Gets the Cantara scheduler running jobs via the REST API within an existing web reqest session.
    .EXAMPLE
    PS C:\> $URI = "http://servername.somedomain:1234/cantaraendpoint"
    PS C:\> Get-CantaraSchedulerJobs -URI $URI -WebSession CantaraSession
    Description
    -----------
    Gets the Cantara scheduler's running jobs via Cantara REST API using the predefined URI and an existing web
    session object.
    .PARAMETER URI
    The URI for the Cantara Scheduler REST API endpoint.
    .PARAMETER WebSession
    The established web request session.
    .INPUTS
    System.String, WebRequestSession
    .OUTPUTS
    None or XmlElement
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

            # Invoke get REST API request
            $Params = @{
            
                Method      = "Get"
                Uri         = "$URI/service/scheduler/running"
                WebSession  = $WebSession
                ContentType = "application/json"
            }
            Write-Debug -Message "Invoking get REST API request to '$URI'"
            Write-Verbose -Message "Invoking get REST API request"
            $Req = Invoke-RestMethod @Params
            if (-not $Req) { throw "An error occurred invoking a get request with the Cantara REST API '$URI'." }

            # Parse the response from the request
            Write-Debug -Message "Parsing the response from the request"
            Write-Verbose -Message "Parsing the response from the request"
            if ($Req.QuartzJobList.PSObject.Properties.Name.Contains("QuartzJobDefinition") -eq $false) {

                Write-Debug -Message "The Cantara scheduler has no running jobs"
                Write-Verbose -Message "The Cantara scheduler has no running jobs"
            }
            else {
                
                Write-Debug -Message "The Cantara scheduler has running jobs:"
                Write-Verbose -Message "The Cantara scheduler has running jobs:"
                Write-Output -InputObject $Req.QuartzJobList.QuartzJobDefinition
            }
        }
        catch { Write-Error -ErrorRecord $PSItem -EA $CallerEA }
    }
}