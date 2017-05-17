Function New-AzureRestAuthorizationHeader 
{ 
[CmdletBinding()] 
    Param 
    ( 
        [Parameter(Mandatory=$true)][String]$ClientId, 
        [Parameter(Mandatory=$true)][String]$ClientKey, 
        [Parameter(Mandatory=$true)][String]$TenantId 
    ) 
    # Import ADAL library to acquire access token 
    # $PSScriptRoot only work PowerShell V3 or above versions 
    Add-Type -Path "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll" 
    Add-Type -Path "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll" 
 
    # Authorization & resource Url 
    $authUrl = "https://login.windows.net/$TenantId/" 
    $resource = "https://management.core.windows.net/" 
 
    # Create credential for client application 
    $clientCred = [Microsoft.IdentityModel.Clients.ActiveDirectory.ClientCredential]::new($ClientId, $ClientKey) 
 
    # Create AuthenticationContext for acquiring token 
    $authContext = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext]::new($authUrl, $false) 
 
    # Acquire the authentication result 
    $authResult = $authContext.AcquireTokenAsync($resource, $clientCred).Result 
 
    # Compose the access token type and access token for authorization header 
    $authHeader = $authResult.AccessTokenType + " " + $authResult.AccessToken 
 
    # the final header hash table 
    return @{"Authorization"=$authHeader; "Content-Type"="application/json"} 
} 
Export-ModuleMember -Function "New-AzureRestAuthorizationHeader"