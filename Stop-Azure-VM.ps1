 Param(
  [string]$VMName,
  [string]$ResourceGroupName
 )  
$connectionName = "AzureRunAsConnection"
 # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
Write-Output "Stopping VM '$($VMName)'in resource group '$($ResourceGroupName)'"
Stop-AzureRmVM -Name $VMName -ResourceGroupName $ResourceGroupName -Force