function Connect-CantaraRESTAPI {

    <#
    .SYNOPSIS
    Connects to the Cantara REST API.
    .DESCRIPTION
    Authtenticates with the Catara scheduler REST API and generates a web request session for subsequent
    interactions, such as getting the status of the scheduler, suspending, resuming, and shutting down.
    .EXAMPLE
    PS C:\> $URI = "http://servername.somedomain:1234/cantaraendpoint"
    PS C:\> $Cred = Get-Credential
    PS C:\> Connect-CantaraRESTAPI -URI $URI -Credential $Cred -SessionName CantaraSession
    Description
    -----------
    Authenticates with the Cantara scheduler REST API using the pre-defined URI and credential objects.
    .PARAMETER URI
    The URI for the Cantara Scheduler REST API endpoint.
    .PARAMETER Credential
    The username and password for the Cantara scheduler REST API endpoint.
    .PARAMETER SessionName
    The name to be used for the web request session.
    .INPUTS
    System.String, pscredential
    .OUTPUTS
    WebRequestSession
    #>

    #Requires -Version 5.1

    [CmdLetBinding()]
    param (
        
        # Cantara scheduler REST API endpoint URI
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias("Endpoint", "URL")]
        [string] $URI,
        
        # Cantara scheduler REST API endpoint username and password
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Alias("Cred")]
        [pscredential] $Credential,

        # Web request session name
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $SessionName
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
            $Data = @{

                name           = "login"
                cantaraVersion = "4.2"
                Parameter      = @(

                    @{
                        name  = "username"
                        value = $Credential.UserName
                    }
                    @{
                        name  = "password"
                        value = $Credential.GetNetworkCredential().Password
                    }
                )
            }
            $Params = @{
            
                Uri             = "$URI/service/configuration/login"
                Method          = "Post"
                SessionVariable = "Sesh"
                Body            = $Data | ConvertTo-Json
                ContentType     = "application/json"
            }
            Write-Debug -Message "Invoking post REST API request to '$URI'"
            Write-Verbose -Message "Invoking post REST API request"
            $Login = Invoke-RestMethod @Params
            if ($Login.Message.'#text' -ne "Transaction Successful") {
            
                throw "An error occurred authenticating with the Cantara REST API '$URI'."
            }

            Write-Debug -Message "Exporting session variable to the global scope with name '$SessionName'"
            Write-Verbose -Message "Exporting session variable to the global scope"
            Set-Variable -Name $SessionName -Value $Sesh -Scope Global -PassThru
        }
        catch { Write-Error -ErrorRecord $PSItem -EA $CallerEA }
    }
}