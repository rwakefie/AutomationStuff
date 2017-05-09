#Globals
$AppName = "ASEB"
$AppHomePage = "https://theclouddc.com/ASEB"
$AppIdentifierUri = "https://theclouddc.com/ASEB"
$VaultName = "ASEB"

# Select certificate generated from Enterprise PKI
# Cert must have minimum RSA 2048-bit key length for Public Key

    $cert = 
        ( Get-ChildItem Cert:\CurrentUser\My |
            Out-GridView `
                -Title "Select a certificate ..." `
                -PassThru
        )

# If not using Enterprise PKI, create self-signed certificate instead

    if (!$cert) {

        $cert = New-SelfSignedCertificate `
            -CertStoreLocation Cert:\CurrentUser\My `
            -Subject "CN=ASEB" `
            -KeySpec KeyExchange `
            -HashAlgorithm SHA256

    }

# Get certificate thumbprint

    $certThumbprint = $cert.Thumbprint

# Get public key and properties from selected cert

    $keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())

    $keyId = [guid]::NewGuid()

    $startDate = $cert.NotBefore

    $endDate = $cert.NotAfter

# Create a Key Credential object for selected cert

    Import-Module -Name AzureRM.Resources

    $keyCredential = 
        New-Object -TypeName Microsoft.Azure.Commands.Resources.Models.ActiveDirectory.PSADKeyCredential

    $keyCredential.StartDate = $startDate

    $keyCredential.EndDate = $endDate

    $keyCredential.KeyId = $keyId

    $keyCredential.CertValue = $keyValue

# Define Azure AD App values for new Service Principal

    $adAppName = $AppName

    $adAppHomePage = $AppHomePage

    $adAppIdentifierUri = $AppIdentifierUri

# Login to Azure as user credentials with Azure Subscription Owner and Azure AD Global Admin access

    Login-AzureRmAccount

# If more than 1 Azure subscription is present, select Azure subscription

    $subscriptionId = 
        ( Get-AzureRmSubscription |
            Out-GridView `
                -Title "Select an Azure Subscription ..." `
                -PassThru
        ).SubscriptionId

    Select-AzureRmSubscription `
        -SubscriptionId $subscriptionId

  # Create Azure AD App object for new Service Principal

    $adApp = 
        New-AzureRmADApplication `
            -DisplayName $adAppName `
            -HomePage $adAppHomePage `
            -IdentifierUris $adAppIdentifierUri `
            -KeyCredentials $keyCredential 

    Write-Output “New Azure AD App Id: $($adApp.ApplicationId)”    

 # Create Service Principal

    New-AzureRmADServicePrincipal `
        -ApplicationId $adApp.ApplicationId

 # Select Azure Resource Group in which to create Key Vault

    $rgName =
        (Get-AzureRmResourceGroup |
         Out-GridView `
            -Title "Select an Azure Resource Group ..." `
            -PassThru).ResourceGroupName

    $rg =
        Get-AzureRmResourceGroup `
            -Name $rgName        

 # Create New Key Vault

    $vaultName = $VaultName

    $vaultSKU = 'Premium'

    New-AzureRmKeyVault `
        -VaultName $vaultName `
        -ResourceGroupName $rgName `
        -Location $rg.Location `
        -SKU $vaultSKU

 # Show current properties of Key Vault

    $vault =
        Get-AzureRmKeyVault `
            -VaultName $vaultName `
            -ResourceGroupName $rgName

    $vault | Format-List

# Assign Key Vault access to new Service Principal

    Set-AzureRmKeyVaultAccessPolicy `
        -VaultName $vaultName `
        -ServicePrincipalName $adApp.ApplicationId `
        -PermissionsToKeys create,get,list,wrapKey,unwrapKey  

# Optional: If demo'ing Azure RBAC delegation, assign RBAC role to new Service Principal and test authenticating to Azure

    New-AzureRmRoleAssignment `
        -RoleDefinitionName Contributor `
        -ServicePrincipalName $adApp.ApplicationId